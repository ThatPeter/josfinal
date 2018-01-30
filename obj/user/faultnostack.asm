
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
  800069:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 04 40 80 00       	mov    %eax,0x804004

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
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	83 ec 08             	sub    $0x8,%esp
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
  8000c3:	e8 0c 0a 00 00       	call   800ad4 <close_all>
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
  80013c:	68 2a 24 80 00       	push   $0x80242a
  800141:	6a 23                	push   $0x23
  800143:	68 47 24 80 00       	push   $0x802447
  800148:	e8 b8 14 00 00       	call   801605 <_panic>

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
  8001bd:	68 2a 24 80 00       	push   $0x80242a
  8001c2:	6a 23                	push   $0x23
  8001c4:	68 47 24 80 00       	push   $0x802447
  8001c9:	e8 37 14 00 00       	call   801605 <_panic>

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
  8001ff:	68 2a 24 80 00       	push   $0x80242a
  800204:	6a 23                	push   $0x23
  800206:	68 47 24 80 00       	push   $0x802447
  80020b:	e8 f5 13 00 00       	call   801605 <_panic>

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
  800241:	68 2a 24 80 00       	push   $0x80242a
  800246:	6a 23                	push   $0x23
  800248:	68 47 24 80 00       	push   $0x802447
  80024d:	e8 b3 13 00 00       	call   801605 <_panic>

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
  800283:	68 2a 24 80 00       	push   $0x80242a
  800288:	6a 23                	push   $0x23
  80028a:	68 47 24 80 00       	push   $0x802447
  80028f:	e8 71 13 00 00       	call   801605 <_panic>

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
  8002c5:	68 2a 24 80 00       	push   $0x80242a
  8002ca:	6a 23                	push   $0x23
  8002cc:	68 47 24 80 00       	push   $0x802447
  8002d1:	e8 2f 13 00 00       	call   801605 <_panic>
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
  800307:	68 2a 24 80 00       	push   $0x80242a
  80030c:	6a 23                	push   $0x23
  80030e:	68 47 24 80 00       	push   $0x802447
  800313:	e8 ed 12 00 00       	call   801605 <_panic>

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
  80036b:	68 2a 24 80 00       	push   $0x80242a
  800370:	6a 23                	push   $0x23
  800372:	68 47 24 80 00       	push   $0x802447
  800377:	e8 89 12 00 00       	call   801605 <_panic>

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
  80042e:	68 55 24 80 00       	push   $0x802455
  800433:	6a 1f                	push   $0x1f
  800435:	68 65 24 80 00       	push   $0x802465
  80043a:	e8 c6 11 00 00       	call   801605 <_panic>
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
  800458:	68 70 24 80 00       	push   $0x802470
  80045d:	6a 2d                	push   $0x2d
  80045f:	68 65 24 80 00       	push   $0x802465
  800464:	e8 9c 11 00 00       	call   801605 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800469:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	68 00 10 00 00       	push   $0x1000
  800477:	53                   	push   %ebx
  800478:	68 00 f0 7f 00       	push   $0x7ff000
  80047d:	e8 db 19 00 00       	call   801e5d <memcpy>

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
  8004a0:	68 70 24 80 00       	push   $0x802470
  8004a5:	6a 34                	push   $0x34
  8004a7:	68 65 24 80 00       	push   $0x802465
  8004ac:	e8 54 11 00 00       	call   801605 <_panic>
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
  8004c8:	68 70 24 80 00       	push   $0x802470
  8004cd:	6a 38                	push   $0x38
  8004cf:	68 65 24 80 00       	push   $0x802465
  8004d4:	e8 2c 11 00 00       	call   801605 <_panic>
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
  8004ec:	e8 b9 1a 00 00       	call   801faa <set_pgfault_handler>
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
  800505:	68 89 24 80 00       	push   $0x802489
  80050a:	68 85 00 00 00       	push   $0x85
  80050f:	68 65 24 80 00       	push   $0x802465
  800514:	e8 ec 10 00 00       	call   801605 <_panic>
  800519:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  80051b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80051f:	75 24                	jne    800545 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800521:	e8 2f fc ff ff       	call   800155 <sys_getenvid>
  800526:	25 ff 03 00 00       	and    $0x3ff,%eax
  80052b:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
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
  8005c1:	68 97 24 80 00       	push   $0x802497
  8005c6:	6a 55                	push   $0x55
  8005c8:	68 65 24 80 00       	push   $0x802465
  8005cd:	e8 33 10 00 00       	call   801605 <_panic>
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
  800606:	68 97 24 80 00       	push   $0x802497
  80060b:	6a 5c                	push   $0x5c
  80060d:	68 65 24 80 00       	push   $0x802465
  800612:	e8 ee 0f 00 00       	call   801605 <_panic>
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
  800634:	68 97 24 80 00       	push   $0x802497
  800639:	6a 60                	push   $0x60
  80063b:	68 65 24 80 00       	push   $0x802465
  800640:	e8 c0 0f 00 00       	call   801605 <_panic>
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
  80065e:	68 97 24 80 00       	push   $0x802497
  800663:	6a 65                	push   $0x65
  800665:	68 65 24 80 00       	push   $0x802465
  80066a:	e8 96 0f 00 00       	call   801605 <_panic>
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
  800686:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
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

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  8006c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c4:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006c9:	68 9d 00 80 00       	push   $0x80009d
  8006ce:	e8 b1 fc ff ff       	call   800384 <sys_thread_create>

	return id;
}
  8006d3:	c9                   	leave  
  8006d4:	c3                   	ret    

008006d5 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8006db:	ff 75 08             	pushl  0x8(%ebp)
  8006de:	e8 c1 fc ff ff       	call   8003a4 <sys_thread_free>
}
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	c9                   	leave  
  8006e7:	c3                   	ret    

008006e8 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8006ee:	ff 75 08             	pushl  0x8(%ebp)
  8006f1:	e8 ce fc ff ff       	call   8003c4 <sys_thread_join>
}
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	c9                   	leave  
  8006fa:	c3                   	ret    

008006fb <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	56                   	push   %esi
  8006ff:	53                   	push   %ebx
  800700:	8b 75 08             	mov    0x8(%ebp),%esi
  800703:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  800706:	83 ec 04             	sub    $0x4,%esp
  800709:	6a 07                	push   $0x7
  80070b:	6a 00                	push   $0x0
  80070d:	56                   	push   %esi
  80070e:	e8 80 fa ff ff       	call   800193 <sys_page_alloc>
	if (r < 0) {
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	85 c0                	test   %eax,%eax
  800718:	79 15                	jns    80072f <queue_append+0x34>
		panic("%e\n", r);
  80071a:	50                   	push   %eax
  80071b:	68 dd 24 80 00       	push   $0x8024dd
  800720:	68 d5 00 00 00       	push   $0xd5
  800725:	68 65 24 80 00       	push   $0x802465
  80072a:	e8 d6 0e 00 00       	call   801605 <_panic>
	}	

	wt->envid = envid;
  80072f:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  800735:	83 3b 00             	cmpl   $0x0,(%ebx)
  800738:	75 13                	jne    80074d <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  80073a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  800741:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800748:	00 00 00 
  80074b:	eb 1b                	jmp    800768 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  80074d:	8b 43 04             	mov    0x4(%ebx),%eax
  800750:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  800757:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80075e:	00 00 00 
		queue->last = wt;
  800761:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  800768:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5d                   	pop    %ebp
  80076e:	c3                   	ret    

0080076f <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  800778:	8b 02                	mov    (%edx),%eax
  80077a:	85 c0                	test   %eax,%eax
  80077c:	75 17                	jne    800795 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  80077e:	83 ec 04             	sub    $0x4,%esp
  800781:	68 ad 24 80 00       	push   $0x8024ad
  800786:	68 ec 00 00 00       	push   $0xec
  80078b:	68 65 24 80 00       	push   $0x802465
  800790:	e8 70 0e 00 00       	call   801605 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  800795:	8b 48 04             	mov    0x4(%eax),%ecx
  800798:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  80079a:	8b 00                	mov    (%eax),%eax
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	56                   	push   %esi
  8007a2:	53                   	push   %ebx
  8007a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8007a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8007ab:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	74 4a                	je     8007fc <mutex_lock+0x5e>
  8007b2:	8b 73 04             	mov    0x4(%ebx),%esi
  8007b5:	83 3e 00             	cmpl   $0x0,(%esi)
  8007b8:	75 42                	jne    8007fc <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  8007ba:	e8 96 f9 ff ff       	call   800155 <sys_getenvid>
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	56                   	push   %esi
  8007c3:	50                   	push   %eax
  8007c4:	e8 32 ff ff ff       	call   8006fb <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8007c9:	e8 87 f9 ff ff       	call   800155 <sys_getenvid>
  8007ce:	83 c4 08             	add    $0x8,%esp
  8007d1:	6a 04                	push   $0x4
  8007d3:	50                   	push   %eax
  8007d4:	e8 81 fa ff ff       	call   80025a <sys_env_set_status>

		if (r < 0) {
  8007d9:	83 c4 10             	add    $0x10,%esp
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	79 15                	jns    8007f5 <mutex_lock+0x57>
			panic("%e\n", r);
  8007e0:	50                   	push   %eax
  8007e1:	68 dd 24 80 00       	push   $0x8024dd
  8007e6:	68 02 01 00 00       	push   $0x102
  8007eb:	68 65 24 80 00       	push   $0x802465
  8007f0:	e8 10 0e 00 00       	call   801605 <_panic>
		}
		sys_yield();
  8007f5:	e8 7a f9 ff ff       	call   800174 <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007fa:	eb 08                	jmp    800804 <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  8007fc:	e8 54 f9 ff ff       	call   800155 <sys_getenvid>
  800801:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  800804:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800807:	5b                   	pop    %ebx
  800808:	5e                   	pop    %esi
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	83 ec 04             	sub    $0x4,%esp
  800812:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800815:	b8 00 00 00 00       	mov    $0x0,%eax
  80081a:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  80081d:	8b 43 04             	mov    0x4(%ebx),%eax
  800820:	83 38 00             	cmpl   $0x0,(%eax)
  800823:	74 33                	je     800858 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  800825:	83 ec 0c             	sub    $0xc,%esp
  800828:	50                   	push   %eax
  800829:	e8 41 ff ff ff       	call   80076f <queue_pop>
  80082e:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  800831:	83 c4 08             	add    $0x8,%esp
  800834:	6a 02                	push   $0x2
  800836:	50                   	push   %eax
  800837:	e8 1e fa ff ff       	call   80025a <sys_env_set_status>
		if (r < 0) {
  80083c:	83 c4 10             	add    $0x10,%esp
  80083f:	85 c0                	test   %eax,%eax
  800841:	79 15                	jns    800858 <mutex_unlock+0x4d>
			panic("%e\n", r);
  800843:	50                   	push   %eax
  800844:	68 dd 24 80 00       	push   $0x8024dd
  800849:	68 16 01 00 00       	push   $0x116
  80084e:	68 65 24 80 00       	push   $0x802465
  800853:	e8 ad 0d 00 00       	call   801605 <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  800858:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	53                   	push   %ebx
  800861:	83 ec 04             	sub    $0x4,%esp
  800864:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  800867:	e8 e9 f8 ff ff       	call   800155 <sys_getenvid>
  80086c:	83 ec 04             	sub    $0x4,%esp
  80086f:	6a 07                	push   $0x7
  800871:	53                   	push   %ebx
  800872:	50                   	push   %eax
  800873:	e8 1b f9 ff ff       	call   800193 <sys_page_alloc>
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	85 c0                	test   %eax,%eax
  80087d:	79 15                	jns    800894 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80087f:	50                   	push   %eax
  800880:	68 c8 24 80 00       	push   $0x8024c8
  800885:	68 22 01 00 00       	push   $0x122
  80088a:	68 65 24 80 00       	push   $0x802465
  80088f:	e8 71 0d 00 00       	call   801605 <_panic>
	}	
	mtx->locked = 0;
  800894:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  80089a:	8b 43 04             	mov    0x4(%ebx),%eax
  80089d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8008a3:	8b 43 04             	mov    0x4(%ebx),%eax
  8008a6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  8008ad:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8008b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	83 ec 04             	sub    $0x4,%esp
  8008c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  8008c3:	eb 21                	jmp    8008e6 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  8008c5:	83 ec 0c             	sub    $0xc,%esp
  8008c8:	50                   	push   %eax
  8008c9:	e8 a1 fe ff ff       	call   80076f <queue_pop>
  8008ce:	83 c4 08             	add    $0x8,%esp
  8008d1:	6a 02                	push   $0x2
  8008d3:	50                   	push   %eax
  8008d4:	e8 81 f9 ff ff       	call   80025a <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  8008d9:	8b 43 04             	mov    0x4(%ebx),%eax
  8008dc:	8b 10                	mov    (%eax),%edx
  8008de:	8b 52 04             	mov    0x4(%edx),%edx
  8008e1:	89 10                	mov    %edx,(%eax)
  8008e3:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  8008e6:	8b 43 04             	mov    0x4(%ebx),%eax
  8008e9:	83 38 00             	cmpl   $0x0,(%eax)
  8008ec:	75 d7                	jne    8008c5 <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008ee:	83 ec 04             	sub    $0x4,%esp
  8008f1:	68 00 10 00 00       	push   $0x1000
  8008f6:	6a 00                	push   $0x0
  8008f8:	53                   	push   %ebx
  8008f9:	e8 aa 14 00 00       	call   801da8 <memset>
	mtx = NULL;
}
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800904:	c9                   	leave  
  800905:	c3                   	ret    

00800906 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	05 00 00 00 30       	add    $0x30000000,%eax
  800911:	c1 e8 0c             	shr    $0xc,%eax
}
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	05 00 00 00 30       	add    $0x30000000,%eax
  800921:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800926:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800933:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800938:	89 c2                	mov    %eax,%edx
  80093a:	c1 ea 16             	shr    $0x16,%edx
  80093d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800944:	f6 c2 01             	test   $0x1,%dl
  800947:	74 11                	je     80095a <fd_alloc+0x2d>
  800949:	89 c2                	mov    %eax,%edx
  80094b:	c1 ea 0c             	shr    $0xc,%edx
  80094e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800955:	f6 c2 01             	test   $0x1,%dl
  800958:	75 09                	jne    800963 <fd_alloc+0x36>
			*fd_store = fd;
  80095a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80095c:	b8 00 00 00 00       	mov    $0x0,%eax
  800961:	eb 17                	jmp    80097a <fd_alloc+0x4d>
  800963:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800968:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80096d:	75 c9                	jne    800938 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80096f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800975:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800982:	83 f8 1f             	cmp    $0x1f,%eax
  800985:	77 36                	ja     8009bd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800987:	c1 e0 0c             	shl    $0xc,%eax
  80098a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80098f:	89 c2                	mov    %eax,%edx
  800991:	c1 ea 16             	shr    $0x16,%edx
  800994:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80099b:	f6 c2 01             	test   $0x1,%dl
  80099e:	74 24                	je     8009c4 <fd_lookup+0x48>
  8009a0:	89 c2                	mov    %eax,%edx
  8009a2:	c1 ea 0c             	shr    $0xc,%edx
  8009a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8009ac:	f6 c2 01             	test   $0x1,%dl
  8009af:	74 1a                	je     8009cb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8009b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b4:	89 02                	mov    %eax,(%edx)
	return 0;
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bb:	eb 13                	jmp    8009d0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8009bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c2:	eb 0c                	jmp    8009d0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8009c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c9:	eb 05                	jmp    8009d0 <fd_lookup+0x54>
  8009cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	83 ec 08             	sub    $0x8,%esp
  8009d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009db:	ba 60 25 80 00       	mov    $0x802560,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8009e0:	eb 13                	jmp    8009f5 <dev_lookup+0x23>
  8009e2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009e5:	39 08                	cmp    %ecx,(%eax)
  8009e7:	75 0c                	jne    8009f5 <dev_lookup+0x23>
			*dev = devtab[i];
  8009e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ec:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f3:	eb 31                	jmp    800a26 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009f5:	8b 02                	mov    (%edx),%eax
  8009f7:	85 c0                	test   %eax,%eax
  8009f9:	75 e7                	jne    8009e2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009fb:	a1 04 40 80 00       	mov    0x804004,%eax
  800a00:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800a06:	83 ec 04             	sub    $0x4,%esp
  800a09:	51                   	push   %ecx
  800a0a:	50                   	push   %eax
  800a0b:	68 e4 24 80 00       	push   $0x8024e4
  800a10:	e8 c9 0c 00 00       	call   8016de <cprintf>
	*dev = 0;
  800a15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a18:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800a1e:	83 c4 10             	add    $0x10,%esp
  800a21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a26:	c9                   	leave  
  800a27:	c3                   	ret    

00800a28 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	83 ec 10             	sub    $0x10,%esp
  800a30:	8b 75 08             	mov    0x8(%ebp),%esi
  800a33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a39:	50                   	push   %eax
  800a3a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a40:	c1 e8 0c             	shr    $0xc,%eax
  800a43:	50                   	push   %eax
  800a44:	e8 33 ff ff ff       	call   80097c <fd_lookup>
  800a49:	83 c4 08             	add    $0x8,%esp
  800a4c:	85 c0                	test   %eax,%eax
  800a4e:	78 05                	js     800a55 <fd_close+0x2d>
	    || fd != fd2)
  800a50:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a53:	74 0c                	je     800a61 <fd_close+0x39>
		return (must_exist ? r : 0);
  800a55:	84 db                	test   %bl,%bl
  800a57:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5c:	0f 44 c2             	cmove  %edx,%eax
  800a5f:	eb 41                	jmp    800aa2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a61:	83 ec 08             	sub    $0x8,%esp
  800a64:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a67:	50                   	push   %eax
  800a68:	ff 36                	pushl  (%esi)
  800a6a:	e8 63 ff ff ff       	call   8009d2 <dev_lookup>
  800a6f:	89 c3                	mov    %eax,%ebx
  800a71:	83 c4 10             	add    $0x10,%esp
  800a74:	85 c0                	test   %eax,%eax
  800a76:	78 1a                	js     800a92 <fd_close+0x6a>
		if (dev->dev_close)
  800a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a7b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a7e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a83:	85 c0                	test   %eax,%eax
  800a85:	74 0b                	je     800a92 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a87:	83 ec 0c             	sub    $0xc,%esp
  800a8a:	56                   	push   %esi
  800a8b:	ff d0                	call   *%eax
  800a8d:	89 c3                	mov    %eax,%ebx
  800a8f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a92:	83 ec 08             	sub    $0x8,%esp
  800a95:	56                   	push   %esi
  800a96:	6a 00                	push   $0x0
  800a98:	e8 7b f7 ff ff       	call   800218 <sys_page_unmap>
	return r;
  800a9d:	83 c4 10             	add    $0x10,%esp
  800aa0:	89 d8                	mov    %ebx,%eax
}
  800aa2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800aaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab2:	50                   	push   %eax
  800ab3:	ff 75 08             	pushl  0x8(%ebp)
  800ab6:	e8 c1 fe ff ff       	call   80097c <fd_lookup>
  800abb:	83 c4 08             	add    $0x8,%esp
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	78 10                	js     800ad2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ac2:	83 ec 08             	sub    $0x8,%esp
  800ac5:	6a 01                	push   $0x1
  800ac7:	ff 75 f4             	pushl  -0xc(%ebp)
  800aca:	e8 59 ff ff ff       	call   800a28 <fd_close>
  800acf:	83 c4 10             	add    $0x10,%esp
}
  800ad2:	c9                   	leave  
  800ad3:	c3                   	ret    

00800ad4 <close_all>:

void
close_all(void)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	53                   	push   %ebx
  800ad8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800adb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ae0:	83 ec 0c             	sub    $0xc,%esp
  800ae3:	53                   	push   %ebx
  800ae4:	e8 c0 ff ff ff       	call   800aa9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ae9:	83 c3 01             	add    $0x1,%ebx
  800aec:	83 c4 10             	add    $0x10,%esp
  800aef:	83 fb 20             	cmp    $0x20,%ebx
  800af2:	75 ec                	jne    800ae0 <close_all+0xc>
		close(i);
}
  800af4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    

00800af9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	83 ec 2c             	sub    $0x2c,%esp
  800b02:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800b05:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800b08:	50                   	push   %eax
  800b09:	ff 75 08             	pushl  0x8(%ebp)
  800b0c:	e8 6b fe ff ff       	call   80097c <fd_lookup>
  800b11:	83 c4 08             	add    $0x8,%esp
  800b14:	85 c0                	test   %eax,%eax
  800b16:	0f 88 c1 00 00 00    	js     800bdd <dup+0xe4>
		return r;
	close(newfdnum);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	56                   	push   %esi
  800b20:	e8 84 ff ff ff       	call   800aa9 <close>

	newfd = INDEX2FD(newfdnum);
  800b25:	89 f3                	mov    %esi,%ebx
  800b27:	c1 e3 0c             	shl    $0xc,%ebx
  800b2a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b30:	83 c4 04             	add    $0x4,%esp
  800b33:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b36:	e8 db fd ff ff       	call   800916 <fd2data>
  800b3b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b3d:	89 1c 24             	mov    %ebx,(%esp)
  800b40:	e8 d1 fd ff ff       	call   800916 <fd2data>
  800b45:	83 c4 10             	add    $0x10,%esp
  800b48:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b4b:	89 f8                	mov    %edi,%eax
  800b4d:	c1 e8 16             	shr    $0x16,%eax
  800b50:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b57:	a8 01                	test   $0x1,%al
  800b59:	74 37                	je     800b92 <dup+0x99>
  800b5b:	89 f8                	mov    %edi,%eax
  800b5d:	c1 e8 0c             	shr    $0xc,%eax
  800b60:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b67:	f6 c2 01             	test   $0x1,%dl
  800b6a:	74 26                	je     800b92 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b6c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	25 07 0e 00 00       	and    $0xe07,%eax
  800b7b:	50                   	push   %eax
  800b7c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b7f:	6a 00                	push   $0x0
  800b81:	57                   	push   %edi
  800b82:	6a 00                	push   $0x0
  800b84:	e8 4d f6 ff ff       	call   8001d6 <sys_page_map>
  800b89:	89 c7                	mov    %eax,%edi
  800b8b:	83 c4 20             	add    $0x20,%esp
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	78 2e                	js     800bc0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b92:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b95:	89 d0                	mov    %edx,%eax
  800b97:	c1 e8 0c             	shr    $0xc,%eax
  800b9a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	25 07 0e 00 00       	and    $0xe07,%eax
  800ba9:	50                   	push   %eax
  800baa:	53                   	push   %ebx
  800bab:	6a 00                	push   $0x0
  800bad:	52                   	push   %edx
  800bae:	6a 00                	push   $0x0
  800bb0:	e8 21 f6 ff ff       	call   8001d6 <sys_page_map>
  800bb5:	89 c7                	mov    %eax,%edi
  800bb7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800bba:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800bbc:	85 ff                	test   %edi,%edi
  800bbe:	79 1d                	jns    800bdd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800bc0:	83 ec 08             	sub    $0x8,%esp
  800bc3:	53                   	push   %ebx
  800bc4:	6a 00                	push   $0x0
  800bc6:	e8 4d f6 ff ff       	call   800218 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800bcb:	83 c4 08             	add    $0x8,%esp
  800bce:	ff 75 d4             	pushl  -0x2c(%ebp)
  800bd1:	6a 00                	push   $0x0
  800bd3:	e8 40 f6 ff ff       	call   800218 <sys_page_unmap>
	return r;
  800bd8:	83 c4 10             	add    $0x10,%esp
  800bdb:	89 f8                	mov    %edi,%eax
}
  800bdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	53                   	push   %ebx
  800be9:	83 ec 14             	sub    $0x14,%esp
  800bec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bf2:	50                   	push   %eax
  800bf3:	53                   	push   %ebx
  800bf4:	e8 83 fd ff ff       	call   80097c <fd_lookup>
  800bf9:	83 c4 08             	add    $0x8,%esp
  800bfc:	89 c2                	mov    %eax,%edx
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	78 70                	js     800c72 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c02:	83 ec 08             	sub    $0x8,%esp
  800c05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c08:	50                   	push   %eax
  800c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c0c:	ff 30                	pushl  (%eax)
  800c0e:	e8 bf fd ff ff       	call   8009d2 <dev_lookup>
  800c13:	83 c4 10             	add    $0x10,%esp
  800c16:	85 c0                	test   %eax,%eax
  800c18:	78 4f                	js     800c69 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800c1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c1d:	8b 42 08             	mov    0x8(%edx),%eax
  800c20:	83 e0 03             	and    $0x3,%eax
  800c23:	83 f8 01             	cmp    $0x1,%eax
  800c26:	75 24                	jne    800c4c <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800c28:	a1 04 40 80 00       	mov    0x804004,%eax
  800c2d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800c33:	83 ec 04             	sub    $0x4,%esp
  800c36:	53                   	push   %ebx
  800c37:	50                   	push   %eax
  800c38:	68 25 25 80 00       	push   $0x802525
  800c3d:	e8 9c 0a 00 00       	call   8016de <cprintf>
		return -E_INVAL;
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c4a:	eb 26                	jmp    800c72 <read+0x8d>
	}
	if (!dev->dev_read)
  800c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c4f:	8b 40 08             	mov    0x8(%eax),%eax
  800c52:	85 c0                	test   %eax,%eax
  800c54:	74 17                	je     800c6d <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c56:	83 ec 04             	sub    $0x4,%esp
  800c59:	ff 75 10             	pushl  0x10(%ebp)
  800c5c:	ff 75 0c             	pushl  0xc(%ebp)
  800c5f:	52                   	push   %edx
  800c60:	ff d0                	call   *%eax
  800c62:	89 c2                	mov    %eax,%edx
  800c64:	83 c4 10             	add    $0x10,%esp
  800c67:	eb 09                	jmp    800c72 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c69:	89 c2                	mov    %eax,%edx
  800c6b:	eb 05                	jmp    800c72 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c6d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c72:	89 d0                	mov    %edx,%eax
  800c74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c77:	c9                   	leave  
  800c78:	c3                   	ret    

00800c79 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c85:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	eb 21                	jmp    800cb0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c8f:	83 ec 04             	sub    $0x4,%esp
  800c92:	89 f0                	mov    %esi,%eax
  800c94:	29 d8                	sub    %ebx,%eax
  800c96:	50                   	push   %eax
  800c97:	89 d8                	mov    %ebx,%eax
  800c99:	03 45 0c             	add    0xc(%ebp),%eax
  800c9c:	50                   	push   %eax
  800c9d:	57                   	push   %edi
  800c9e:	e8 42 ff ff ff       	call   800be5 <read>
		if (m < 0)
  800ca3:	83 c4 10             	add    $0x10,%esp
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	78 10                	js     800cba <readn+0x41>
			return m;
		if (m == 0)
  800caa:	85 c0                	test   %eax,%eax
  800cac:	74 0a                	je     800cb8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800cae:	01 c3                	add    %eax,%ebx
  800cb0:	39 f3                	cmp    %esi,%ebx
  800cb2:	72 db                	jb     800c8f <readn+0x16>
  800cb4:	89 d8                	mov    %ebx,%eax
  800cb6:	eb 02                	jmp    800cba <readn+0x41>
  800cb8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	53                   	push   %ebx
  800cc6:	83 ec 14             	sub    $0x14,%esp
  800cc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ccc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ccf:	50                   	push   %eax
  800cd0:	53                   	push   %ebx
  800cd1:	e8 a6 fc ff ff       	call   80097c <fd_lookup>
  800cd6:	83 c4 08             	add    $0x8,%esp
  800cd9:	89 c2                	mov    %eax,%edx
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	78 6b                	js     800d4a <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cdf:	83 ec 08             	sub    $0x8,%esp
  800ce2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ce5:	50                   	push   %eax
  800ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ce9:	ff 30                	pushl  (%eax)
  800ceb:	e8 e2 fc ff ff       	call   8009d2 <dev_lookup>
  800cf0:	83 c4 10             	add    $0x10,%esp
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	78 4a                	js     800d41 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cfa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cfe:	75 24                	jne    800d24 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800d00:	a1 04 40 80 00       	mov    0x804004,%eax
  800d05:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800d0b:	83 ec 04             	sub    $0x4,%esp
  800d0e:	53                   	push   %ebx
  800d0f:	50                   	push   %eax
  800d10:	68 41 25 80 00       	push   $0x802541
  800d15:	e8 c4 09 00 00       	call   8016de <cprintf>
		return -E_INVAL;
  800d1a:	83 c4 10             	add    $0x10,%esp
  800d1d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d22:	eb 26                	jmp    800d4a <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800d24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d27:	8b 52 0c             	mov    0xc(%edx),%edx
  800d2a:	85 d2                	test   %edx,%edx
  800d2c:	74 17                	je     800d45 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d2e:	83 ec 04             	sub    $0x4,%esp
  800d31:	ff 75 10             	pushl  0x10(%ebp)
  800d34:	ff 75 0c             	pushl  0xc(%ebp)
  800d37:	50                   	push   %eax
  800d38:	ff d2                	call   *%edx
  800d3a:	89 c2                	mov    %eax,%edx
  800d3c:	83 c4 10             	add    $0x10,%esp
  800d3f:	eb 09                	jmp    800d4a <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d41:	89 c2                	mov    %eax,%edx
  800d43:	eb 05                	jmp    800d4a <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d45:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d4a:	89 d0                	mov    %edx,%eax
  800d4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d4f:	c9                   	leave  
  800d50:	c3                   	ret    

00800d51 <seek>:

int
seek(int fdnum, off_t offset)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d57:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d5a:	50                   	push   %eax
  800d5b:	ff 75 08             	pushl  0x8(%ebp)
  800d5e:	e8 19 fc ff ff       	call   80097c <fd_lookup>
  800d63:	83 c4 08             	add    $0x8,%esp
  800d66:	85 c0                	test   %eax,%eax
  800d68:	78 0e                	js     800d78 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d70:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d78:	c9                   	leave  
  800d79:	c3                   	ret    

00800d7a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	53                   	push   %ebx
  800d7e:	83 ec 14             	sub    $0x14,%esp
  800d81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d84:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d87:	50                   	push   %eax
  800d88:	53                   	push   %ebx
  800d89:	e8 ee fb ff ff       	call   80097c <fd_lookup>
  800d8e:	83 c4 08             	add    $0x8,%esp
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	85 c0                	test   %eax,%eax
  800d95:	78 68                	js     800dff <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d97:	83 ec 08             	sub    $0x8,%esp
  800d9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d9d:	50                   	push   %eax
  800d9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800da1:	ff 30                	pushl  (%eax)
  800da3:	e8 2a fc ff ff       	call   8009d2 <dev_lookup>
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	85 c0                	test   %eax,%eax
  800dad:	78 47                	js     800df6 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800db2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800db6:	75 24                	jne    800ddc <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800db8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800dbd:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800dc3:	83 ec 04             	sub    $0x4,%esp
  800dc6:	53                   	push   %ebx
  800dc7:	50                   	push   %eax
  800dc8:	68 04 25 80 00       	push   $0x802504
  800dcd:	e8 0c 09 00 00       	call   8016de <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800dd2:	83 c4 10             	add    $0x10,%esp
  800dd5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800dda:	eb 23                	jmp    800dff <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800ddc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ddf:	8b 52 18             	mov    0x18(%edx),%edx
  800de2:	85 d2                	test   %edx,%edx
  800de4:	74 14                	je     800dfa <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800de6:	83 ec 08             	sub    $0x8,%esp
  800de9:	ff 75 0c             	pushl  0xc(%ebp)
  800dec:	50                   	push   %eax
  800ded:	ff d2                	call   *%edx
  800def:	89 c2                	mov    %eax,%edx
  800df1:	83 c4 10             	add    $0x10,%esp
  800df4:	eb 09                	jmp    800dff <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800df6:	89 c2                	mov    %eax,%edx
  800df8:	eb 05                	jmp    800dff <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800dfa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800dff:	89 d0                	mov    %edx,%eax
  800e01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e04:	c9                   	leave  
  800e05:	c3                   	ret    

00800e06 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	53                   	push   %ebx
  800e0a:	83 ec 14             	sub    $0x14,%esp
  800e0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e10:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e13:	50                   	push   %eax
  800e14:	ff 75 08             	pushl  0x8(%ebp)
  800e17:	e8 60 fb ff ff       	call   80097c <fd_lookup>
  800e1c:	83 c4 08             	add    $0x8,%esp
  800e1f:	89 c2                	mov    %eax,%edx
  800e21:	85 c0                	test   %eax,%eax
  800e23:	78 58                	js     800e7d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e25:	83 ec 08             	sub    $0x8,%esp
  800e28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e2b:	50                   	push   %eax
  800e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2f:	ff 30                	pushl  (%eax)
  800e31:	e8 9c fb ff ff       	call   8009d2 <dev_lookup>
  800e36:	83 c4 10             	add    $0x10,%esp
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	78 37                	js     800e74 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e40:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e44:	74 32                	je     800e78 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e46:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e49:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e50:	00 00 00 
	stat->st_isdir = 0;
  800e53:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e5a:	00 00 00 
	stat->st_dev = dev;
  800e5d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e63:	83 ec 08             	sub    $0x8,%esp
  800e66:	53                   	push   %ebx
  800e67:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6a:	ff 50 14             	call   *0x14(%eax)
  800e6d:	89 c2                	mov    %eax,%edx
  800e6f:	83 c4 10             	add    $0x10,%esp
  800e72:	eb 09                	jmp    800e7d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e74:	89 c2                	mov    %eax,%edx
  800e76:	eb 05                	jmp    800e7d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e78:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e7d:	89 d0                	mov    %edx,%eax
  800e7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e89:	83 ec 08             	sub    $0x8,%esp
  800e8c:	6a 00                	push   $0x0
  800e8e:	ff 75 08             	pushl  0x8(%ebp)
  800e91:	e8 e3 01 00 00       	call   801079 <open>
  800e96:	89 c3                	mov    %eax,%ebx
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	78 1b                	js     800eba <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e9f:	83 ec 08             	sub    $0x8,%esp
  800ea2:	ff 75 0c             	pushl  0xc(%ebp)
  800ea5:	50                   	push   %eax
  800ea6:	e8 5b ff ff ff       	call   800e06 <fstat>
  800eab:	89 c6                	mov    %eax,%esi
	close(fd);
  800ead:	89 1c 24             	mov    %ebx,(%esp)
  800eb0:	e8 f4 fb ff ff       	call   800aa9 <close>
	return r;
  800eb5:	83 c4 10             	add    $0x10,%esp
  800eb8:	89 f0                	mov    %esi,%eax
}
  800eba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ebd:	5b                   	pop    %ebx
  800ebe:	5e                   	pop    %esi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	56                   	push   %esi
  800ec5:	53                   	push   %ebx
  800ec6:	89 c6                	mov    %eax,%esi
  800ec8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800eca:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800ed1:	75 12                	jne    800ee5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ed3:	83 ec 0c             	sub    $0xc,%esp
  800ed6:	6a 01                	push   $0x1
  800ed8:	e8 15 12 00 00       	call   8020f2 <ipc_find_env>
  800edd:	a3 00 40 80 00       	mov    %eax,0x804000
  800ee2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ee5:	6a 07                	push   $0x7
  800ee7:	68 00 50 80 00       	push   $0x805000
  800eec:	56                   	push   %esi
  800eed:	ff 35 00 40 80 00    	pushl  0x804000
  800ef3:	e8 98 11 00 00       	call   802090 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ef8:	83 c4 0c             	add    $0xc,%esp
  800efb:	6a 00                	push   $0x0
  800efd:	53                   	push   %ebx
  800efe:	6a 00                	push   $0x0
  800f00:	e8 10 11 00 00       	call   802015 <ipc_recv>
}
  800f05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800f12:	8b 45 08             	mov    0x8(%ebp),%eax
  800f15:	8b 40 0c             	mov    0xc(%eax),%eax
  800f18:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f20:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800f25:	ba 00 00 00 00       	mov    $0x0,%edx
  800f2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800f2f:	e8 8d ff ff ff       	call   800ec1 <fsipc>
}
  800f34:	c9                   	leave  
  800f35:	c3                   	ret    

00800f36 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3f:	8b 40 0c             	mov    0xc(%eax),%eax
  800f42:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f47:	ba 00 00 00 00       	mov    $0x0,%edx
  800f4c:	b8 06 00 00 00       	mov    $0x6,%eax
  800f51:	e8 6b ff ff ff       	call   800ec1 <fsipc>
}
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	53                   	push   %ebx
  800f5c:	83 ec 04             	sub    $0x4,%esp
  800f5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f62:	8b 45 08             	mov    0x8(%ebp),%eax
  800f65:	8b 40 0c             	mov    0xc(%eax),%eax
  800f68:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f72:	b8 05 00 00 00       	mov    $0x5,%eax
  800f77:	e8 45 ff ff ff       	call   800ec1 <fsipc>
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	78 2c                	js     800fac <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f80:	83 ec 08             	sub    $0x8,%esp
  800f83:	68 00 50 80 00       	push   $0x805000
  800f88:	53                   	push   %ebx
  800f89:	e8 d5 0c 00 00       	call   801c63 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f8e:	a1 80 50 80 00       	mov    0x805080,%eax
  800f93:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f99:	a1 84 50 80 00       	mov    0x805084,%eax
  800f9e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 0c             	sub    $0xc,%esp
  800fb7:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800fba:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbd:	8b 52 0c             	mov    0xc(%edx),%edx
  800fc0:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800fc6:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800fcb:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800fd0:	0f 47 c2             	cmova  %edx,%eax
  800fd3:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800fd8:	50                   	push   %eax
  800fd9:	ff 75 0c             	pushl  0xc(%ebp)
  800fdc:	68 08 50 80 00       	push   $0x805008
  800fe1:	e8 0f 0e 00 00       	call   801df5 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fe6:	ba 00 00 00 00       	mov    $0x0,%edx
  800feb:	b8 04 00 00 00       	mov    $0x4,%eax
  800ff0:	e8 cc fe ff ff       	call   800ec1 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fff:	8b 45 08             	mov    0x8(%ebp),%eax
  801002:	8b 40 0c             	mov    0xc(%eax),%eax
  801005:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80100a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801010:	ba 00 00 00 00       	mov    $0x0,%edx
  801015:	b8 03 00 00 00       	mov    $0x3,%eax
  80101a:	e8 a2 fe ff ff       	call   800ec1 <fsipc>
  80101f:	89 c3                	mov    %eax,%ebx
  801021:	85 c0                	test   %eax,%eax
  801023:	78 4b                	js     801070 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801025:	39 c6                	cmp    %eax,%esi
  801027:	73 16                	jae    80103f <devfile_read+0x48>
  801029:	68 70 25 80 00       	push   $0x802570
  80102e:	68 77 25 80 00       	push   $0x802577
  801033:	6a 7c                	push   $0x7c
  801035:	68 8c 25 80 00       	push   $0x80258c
  80103a:	e8 c6 05 00 00       	call   801605 <_panic>
	assert(r <= PGSIZE);
  80103f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801044:	7e 16                	jle    80105c <devfile_read+0x65>
  801046:	68 97 25 80 00       	push   $0x802597
  80104b:	68 77 25 80 00       	push   $0x802577
  801050:	6a 7d                	push   $0x7d
  801052:	68 8c 25 80 00       	push   $0x80258c
  801057:	e8 a9 05 00 00       	call   801605 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80105c:	83 ec 04             	sub    $0x4,%esp
  80105f:	50                   	push   %eax
  801060:	68 00 50 80 00       	push   $0x805000
  801065:	ff 75 0c             	pushl  0xc(%ebp)
  801068:	e8 88 0d 00 00       	call   801df5 <memmove>
	return r;
  80106d:	83 c4 10             	add    $0x10,%esp
}
  801070:	89 d8                	mov    %ebx,%eax
  801072:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801075:	5b                   	pop    %ebx
  801076:	5e                   	pop    %esi
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    

00801079 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	53                   	push   %ebx
  80107d:	83 ec 20             	sub    $0x20,%esp
  801080:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801083:	53                   	push   %ebx
  801084:	e8 a1 0b 00 00       	call   801c2a <strlen>
  801089:	83 c4 10             	add    $0x10,%esp
  80108c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801091:	7f 67                	jg     8010fa <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801099:	50                   	push   %eax
  80109a:	e8 8e f8 ff ff       	call   80092d <fd_alloc>
  80109f:	83 c4 10             	add    $0x10,%esp
		return r;
  8010a2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	78 57                	js     8010ff <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8010a8:	83 ec 08             	sub    $0x8,%esp
  8010ab:	53                   	push   %ebx
  8010ac:	68 00 50 80 00       	push   $0x805000
  8010b1:	e8 ad 0b 00 00       	call   801c63 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8010b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8010be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c6:	e8 f6 fd ff ff       	call   800ec1 <fsipc>
  8010cb:	89 c3                	mov    %eax,%ebx
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	79 14                	jns    8010e8 <open+0x6f>
		fd_close(fd, 0);
  8010d4:	83 ec 08             	sub    $0x8,%esp
  8010d7:	6a 00                	push   $0x0
  8010d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8010dc:	e8 47 f9 ff ff       	call   800a28 <fd_close>
		return r;
  8010e1:	83 c4 10             	add    $0x10,%esp
  8010e4:	89 da                	mov    %ebx,%edx
  8010e6:	eb 17                	jmp    8010ff <open+0x86>
	}

	return fd2num(fd);
  8010e8:	83 ec 0c             	sub    $0xc,%esp
  8010eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ee:	e8 13 f8 ff ff       	call   800906 <fd2num>
  8010f3:	89 c2                	mov    %eax,%edx
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	eb 05                	jmp    8010ff <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010fa:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010ff:	89 d0                	mov    %edx,%eax
  801101:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801104:	c9                   	leave  
  801105:	c3                   	ret    

00801106 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80110c:	ba 00 00 00 00       	mov    $0x0,%edx
  801111:	b8 08 00 00 00       	mov    $0x8,%eax
  801116:	e8 a6 fd ff ff       	call   800ec1 <fsipc>
}
  80111b:	c9                   	leave  
  80111c:	c3                   	ret    

0080111d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	56                   	push   %esi
  801121:	53                   	push   %ebx
  801122:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801125:	83 ec 0c             	sub    $0xc,%esp
  801128:	ff 75 08             	pushl  0x8(%ebp)
  80112b:	e8 e6 f7 ff ff       	call   800916 <fd2data>
  801130:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801132:	83 c4 08             	add    $0x8,%esp
  801135:	68 a3 25 80 00       	push   $0x8025a3
  80113a:	53                   	push   %ebx
  80113b:	e8 23 0b 00 00       	call   801c63 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801140:	8b 46 04             	mov    0x4(%esi),%eax
  801143:	2b 06                	sub    (%esi),%eax
  801145:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80114b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801152:	00 00 00 
	stat->st_dev = &devpipe;
  801155:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80115c:	30 80 00 
	return 0;
}
  80115f:	b8 00 00 00 00       	mov    $0x0,%eax
  801164:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801167:	5b                   	pop    %ebx
  801168:	5e                   	pop    %esi
  801169:	5d                   	pop    %ebp
  80116a:	c3                   	ret    

0080116b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	53                   	push   %ebx
  80116f:	83 ec 0c             	sub    $0xc,%esp
  801172:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801175:	53                   	push   %ebx
  801176:	6a 00                	push   $0x0
  801178:	e8 9b f0 ff ff       	call   800218 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80117d:	89 1c 24             	mov    %ebx,(%esp)
  801180:	e8 91 f7 ff ff       	call   800916 <fd2data>
  801185:	83 c4 08             	add    $0x8,%esp
  801188:	50                   	push   %eax
  801189:	6a 00                	push   $0x0
  80118b:	e8 88 f0 ff ff       	call   800218 <sys_page_unmap>
}
  801190:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801193:	c9                   	leave  
  801194:	c3                   	ret    

00801195 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	57                   	push   %edi
  801199:	56                   	push   %esi
  80119a:	53                   	push   %ebx
  80119b:	83 ec 1c             	sub    $0x1c,%esp
  80119e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011a1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8011a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a8:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8011ae:	83 ec 0c             	sub    $0xc,%esp
  8011b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b4:	e8 7e 0f 00 00       	call   802137 <pageref>
  8011b9:	89 c3                	mov    %eax,%ebx
  8011bb:	89 3c 24             	mov    %edi,(%esp)
  8011be:	e8 74 0f 00 00       	call   802137 <pageref>
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	39 c3                	cmp    %eax,%ebx
  8011c8:	0f 94 c1             	sete   %cl
  8011cb:	0f b6 c9             	movzbl %cl,%ecx
  8011ce:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8011d1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8011d7:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  8011dd:	39 ce                	cmp    %ecx,%esi
  8011df:	74 1e                	je     8011ff <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8011e1:	39 c3                	cmp    %eax,%ebx
  8011e3:	75 be                	jne    8011a3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011e5:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ee:	50                   	push   %eax
  8011ef:	56                   	push   %esi
  8011f0:	68 aa 25 80 00       	push   $0x8025aa
  8011f5:	e8 e4 04 00 00       	call   8016de <cprintf>
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	eb a4                	jmp    8011a3 <_pipeisclosed+0xe>
	}
}
  8011ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801202:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801205:	5b                   	pop    %ebx
  801206:	5e                   	pop    %esi
  801207:	5f                   	pop    %edi
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    

0080120a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	57                   	push   %edi
  80120e:	56                   	push   %esi
  80120f:	53                   	push   %ebx
  801210:	83 ec 28             	sub    $0x28,%esp
  801213:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801216:	56                   	push   %esi
  801217:	e8 fa f6 ff ff       	call   800916 <fd2data>
  80121c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	bf 00 00 00 00       	mov    $0x0,%edi
  801226:	eb 4b                	jmp    801273 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801228:	89 da                	mov    %ebx,%edx
  80122a:	89 f0                	mov    %esi,%eax
  80122c:	e8 64 ff ff ff       	call   801195 <_pipeisclosed>
  801231:	85 c0                	test   %eax,%eax
  801233:	75 48                	jne    80127d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801235:	e8 3a ef ff ff       	call   800174 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80123a:	8b 43 04             	mov    0x4(%ebx),%eax
  80123d:	8b 0b                	mov    (%ebx),%ecx
  80123f:	8d 51 20             	lea    0x20(%ecx),%edx
  801242:	39 d0                	cmp    %edx,%eax
  801244:	73 e2                	jae    801228 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801246:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801249:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80124d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801250:	89 c2                	mov    %eax,%edx
  801252:	c1 fa 1f             	sar    $0x1f,%edx
  801255:	89 d1                	mov    %edx,%ecx
  801257:	c1 e9 1b             	shr    $0x1b,%ecx
  80125a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80125d:	83 e2 1f             	and    $0x1f,%edx
  801260:	29 ca                	sub    %ecx,%edx
  801262:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801266:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80126a:	83 c0 01             	add    $0x1,%eax
  80126d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801270:	83 c7 01             	add    $0x1,%edi
  801273:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801276:	75 c2                	jne    80123a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801278:	8b 45 10             	mov    0x10(%ebp),%eax
  80127b:	eb 05                	jmp    801282 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80127d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801285:	5b                   	pop    %ebx
  801286:	5e                   	pop    %esi
  801287:	5f                   	pop    %edi
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	57                   	push   %edi
  80128e:	56                   	push   %esi
  80128f:	53                   	push   %ebx
  801290:	83 ec 18             	sub    $0x18,%esp
  801293:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801296:	57                   	push   %edi
  801297:	e8 7a f6 ff ff       	call   800916 <fd2data>
  80129c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012a6:	eb 3d                	jmp    8012e5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8012a8:	85 db                	test   %ebx,%ebx
  8012aa:	74 04                	je     8012b0 <devpipe_read+0x26>
				return i;
  8012ac:	89 d8                	mov    %ebx,%eax
  8012ae:	eb 44                	jmp    8012f4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8012b0:	89 f2                	mov    %esi,%edx
  8012b2:	89 f8                	mov    %edi,%eax
  8012b4:	e8 dc fe ff ff       	call   801195 <_pipeisclosed>
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	75 32                	jne    8012ef <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8012bd:	e8 b2 ee ff ff       	call   800174 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8012c2:	8b 06                	mov    (%esi),%eax
  8012c4:	3b 46 04             	cmp    0x4(%esi),%eax
  8012c7:	74 df                	je     8012a8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8012c9:	99                   	cltd   
  8012ca:	c1 ea 1b             	shr    $0x1b,%edx
  8012cd:	01 d0                	add    %edx,%eax
  8012cf:	83 e0 1f             	and    $0x1f,%eax
  8012d2:	29 d0                	sub    %edx,%eax
  8012d4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8012d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012dc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8012df:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012e2:	83 c3 01             	add    $0x1,%ebx
  8012e5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012e8:	75 d8                	jne    8012c2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8012ed:	eb 05                	jmp    8012f4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012ef:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5e                   	pop    %esi
  8012f9:	5f                   	pop    %edi
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	56                   	push   %esi
  801300:	53                   	push   %ebx
  801301:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801304:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801307:	50                   	push   %eax
  801308:	e8 20 f6 ff ff       	call   80092d <fd_alloc>
  80130d:	83 c4 10             	add    $0x10,%esp
  801310:	89 c2                	mov    %eax,%edx
  801312:	85 c0                	test   %eax,%eax
  801314:	0f 88 2c 01 00 00    	js     801446 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80131a:	83 ec 04             	sub    $0x4,%esp
  80131d:	68 07 04 00 00       	push   $0x407
  801322:	ff 75 f4             	pushl  -0xc(%ebp)
  801325:	6a 00                	push   $0x0
  801327:	e8 67 ee ff ff       	call   800193 <sys_page_alloc>
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	89 c2                	mov    %eax,%edx
  801331:	85 c0                	test   %eax,%eax
  801333:	0f 88 0d 01 00 00    	js     801446 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801339:	83 ec 0c             	sub    $0xc,%esp
  80133c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133f:	50                   	push   %eax
  801340:	e8 e8 f5 ff ff       	call   80092d <fd_alloc>
  801345:	89 c3                	mov    %eax,%ebx
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	85 c0                	test   %eax,%eax
  80134c:	0f 88 e2 00 00 00    	js     801434 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801352:	83 ec 04             	sub    $0x4,%esp
  801355:	68 07 04 00 00       	push   $0x407
  80135a:	ff 75 f0             	pushl  -0x10(%ebp)
  80135d:	6a 00                	push   $0x0
  80135f:	e8 2f ee ff ff       	call   800193 <sys_page_alloc>
  801364:	89 c3                	mov    %eax,%ebx
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	85 c0                	test   %eax,%eax
  80136b:	0f 88 c3 00 00 00    	js     801434 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801371:	83 ec 0c             	sub    $0xc,%esp
  801374:	ff 75 f4             	pushl  -0xc(%ebp)
  801377:	e8 9a f5 ff ff       	call   800916 <fd2data>
  80137c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80137e:	83 c4 0c             	add    $0xc,%esp
  801381:	68 07 04 00 00       	push   $0x407
  801386:	50                   	push   %eax
  801387:	6a 00                	push   $0x0
  801389:	e8 05 ee ff ff       	call   800193 <sys_page_alloc>
  80138e:	89 c3                	mov    %eax,%ebx
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	85 c0                	test   %eax,%eax
  801395:	0f 88 89 00 00 00    	js     801424 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80139b:	83 ec 0c             	sub    $0xc,%esp
  80139e:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a1:	e8 70 f5 ff ff       	call   800916 <fd2data>
  8013a6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8013ad:	50                   	push   %eax
  8013ae:	6a 00                	push   $0x0
  8013b0:	56                   	push   %esi
  8013b1:	6a 00                	push   $0x0
  8013b3:	e8 1e ee ff ff       	call   8001d6 <sys_page_map>
  8013b8:	89 c3                	mov    %eax,%ebx
  8013ba:	83 c4 20             	add    $0x20,%esp
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	78 55                	js     801416 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8013c1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ca:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8013cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8013d6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013df:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8013e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013eb:	83 ec 0c             	sub    $0xc,%esp
  8013ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8013f1:	e8 10 f5 ff ff       	call   800906 <fd2num>
  8013f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013fb:	83 c4 04             	add    $0x4,%esp
  8013fe:	ff 75 f0             	pushl  -0x10(%ebp)
  801401:	e8 00 f5 ff ff       	call   800906 <fd2num>
  801406:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801409:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	ba 00 00 00 00       	mov    $0x0,%edx
  801414:	eb 30                	jmp    801446 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801416:	83 ec 08             	sub    $0x8,%esp
  801419:	56                   	push   %esi
  80141a:	6a 00                	push   $0x0
  80141c:	e8 f7 ed ff ff       	call   800218 <sys_page_unmap>
  801421:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	ff 75 f0             	pushl  -0x10(%ebp)
  80142a:	6a 00                	push   $0x0
  80142c:	e8 e7 ed ff ff       	call   800218 <sys_page_unmap>
  801431:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	ff 75 f4             	pushl  -0xc(%ebp)
  80143a:	6a 00                	push   $0x0
  80143c:	e8 d7 ed ff ff       	call   800218 <sys_page_unmap>
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801446:	89 d0                	mov    %edx,%eax
  801448:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144b:	5b                   	pop    %ebx
  80144c:	5e                   	pop    %esi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    

0080144f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801455:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801458:	50                   	push   %eax
  801459:	ff 75 08             	pushl  0x8(%ebp)
  80145c:	e8 1b f5 ff ff       	call   80097c <fd_lookup>
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	85 c0                	test   %eax,%eax
  801466:	78 18                	js     801480 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801468:	83 ec 0c             	sub    $0xc,%esp
  80146b:	ff 75 f4             	pushl  -0xc(%ebp)
  80146e:	e8 a3 f4 ff ff       	call   800916 <fd2data>
	return _pipeisclosed(fd, p);
  801473:	89 c2                	mov    %eax,%edx
  801475:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801478:	e8 18 fd ff ff       	call   801195 <_pipeisclosed>
  80147d:	83 c4 10             	add    $0x10,%esp
}
  801480:	c9                   	leave  
  801481:	c3                   	ret    

00801482 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801485:	b8 00 00 00 00       	mov    $0x0,%eax
  80148a:	5d                   	pop    %ebp
  80148b:	c3                   	ret    

0080148c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801492:	68 c2 25 80 00       	push   $0x8025c2
  801497:	ff 75 0c             	pushl  0xc(%ebp)
  80149a:	e8 c4 07 00 00       	call   801c63 <strcpy>
	return 0;
}
  80149f:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	57                   	push   %edi
  8014aa:	56                   	push   %esi
  8014ab:	53                   	push   %ebx
  8014ac:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014b2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014b7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014bd:	eb 2d                	jmp    8014ec <devcons_write+0x46>
		m = n - tot;
  8014bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014c2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8014c4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8014c7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8014cc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014cf:	83 ec 04             	sub    $0x4,%esp
  8014d2:	53                   	push   %ebx
  8014d3:	03 45 0c             	add    0xc(%ebp),%eax
  8014d6:	50                   	push   %eax
  8014d7:	57                   	push   %edi
  8014d8:	e8 18 09 00 00       	call   801df5 <memmove>
		sys_cputs(buf, m);
  8014dd:	83 c4 08             	add    $0x8,%esp
  8014e0:	53                   	push   %ebx
  8014e1:	57                   	push   %edi
  8014e2:	e8 f0 eb ff ff       	call   8000d7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014e7:	01 de                	add    %ebx,%esi
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	89 f0                	mov    %esi,%eax
  8014ee:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014f1:	72 cc                	jb     8014bf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f6:	5b                   	pop    %ebx
  8014f7:	5e                   	pop    %esi
  8014f8:	5f                   	pop    %edi
  8014f9:	5d                   	pop    %ebp
  8014fa:	c3                   	ret    

008014fb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	83 ec 08             	sub    $0x8,%esp
  801501:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801506:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80150a:	74 2a                	je     801536 <devcons_read+0x3b>
  80150c:	eb 05                	jmp    801513 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80150e:	e8 61 ec ff ff       	call   800174 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801513:	e8 dd eb ff ff       	call   8000f5 <sys_cgetc>
  801518:	85 c0                	test   %eax,%eax
  80151a:	74 f2                	je     80150e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 16                	js     801536 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801520:	83 f8 04             	cmp    $0x4,%eax
  801523:	74 0c                	je     801531 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801525:	8b 55 0c             	mov    0xc(%ebp),%edx
  801528:	88 02                	mov    %al,(%edx)
	return 1;
  80152a:	b8 01 00 00 00       	mov    $0x1,%eax
  80152f:	eb 05                	jmp    801536 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801531:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801536:	c9                   	leave  
  801537:	c3                   	ret    

00801538 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80153e:	8b 45 08             	mov    0x8(%ebp),%eax
  801541:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801544:	6a 01                	push   $0x1
  801546:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	e8 88 eb ff ff       	call   8000d7 <sys_cputs>
}
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	c9                   	leave  
  801553:	c3                   	ret    

00801554 <getchar>:

int
getchar(void)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80155a:	6a 01                	push   $0x1
  80155c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	6a 00                	push   $0x0
  801562:	e8 7e f6 ff ff       	call   800be5 <read>
	if (r < 0)
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 0f                	js     80157d <getchar+0x29>
		return r;
	if (r < 1)
  80156e:	85 c0                	test   %eax,%eax
  801570:	7e 06                	jle    801578 <getchar+0x24>
		return -E_EOF;
	return c;
  801572:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801576:	eb 05                	jmp    80157d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801578:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80157d:	c9                   	leave  
  80157e:	c3                   	ret    

0080157f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
  801582:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801585:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	ff 75 08             	pushl  0x8(%ebp)
  80158c:	e8 eb f3 ff ff       	call   80097c <fd_lookup>
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	78 11                	js     8015a9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801598:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015a1:	39 10                	cmp    %edx,(%eax)
  8015a3:	0f 94 c0             	sete   %al
  8015a6:	0f b6 c0             	movzbl %al,%eax
}
  8015a9:	c9                   	leave  
  8015aa:	c3                   	ret    

008015ab <opencons>:

int
opencons(void)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8015b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b4:	50                   	push   %eax
  8015b5:	e8 73 f3 ff ff       	call   80092d <fd_alloc>
  8015ba:	83 c4 10             	add    $0x10,%esp
		return r;
  8015bd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 3e                	js     801601 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015c3:	83 ec 04             	sub    $0x4,%esp
  8015c6:	68 07 04 00 00       	push   $0x407
  8015cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ce:	6a 00                	push   $0x0
  8015d0:	e8 be eb ff ff       	call   800193 <sys_page_alloc>
  8015d5:	83 c4 10             	add    $0x10,%esp
		return r;
  8015d8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 23                	js     801601 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8015de:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ec:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015f3:	83 ec 0c             	sub    $0xc,%esp
  8015f6:	50                   	push   %eax
  8015f7:	e8 0a f3 ff ff       	call   800906 <fd2num>
  8015fc:	89 c2                	mov    %eax,%edx
  8015fe:	83 c4 10             	add    $0x10,%esp
}
  801601:	89 d0                	mov    %edx,%eax
  801603:	c9                   	leave  
  801604:	c3                   	ret    

00801605 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	56                   	push   %esi
  801609:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80160a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80160d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801613:	e8 3d eb ff ff       	call   800155 <sys_getenvid>
  801618:	83 ec 0c             	sub    $0xc,%esp
  80161b:	ff 75 0c             	pushl  0xc(%ebp)
  80161e:	ff 75 08             	pushl  0x8(%ebp)
  801621:	56                   	push   %esi
  801622:	50                   	push   %eax
  801623:	68 d0 25 80 00       	push   $0x8025d0
  801628:	e8 b1 00 00 00       	call   8016de <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80162d:	83 c4 18             	add    $0x18,%esp
  801630:	53                   	push   %ebx
  801631:	ff 75 10             	pushl  0x10(%ebp)
  801634:	e8 54 00 00 00       	call   80168d <vcprintf>
	cprintf("\n");
  801639:	c7 04 24 c6 24 80 00 	movl   $0x8024c6,(%esp)
  801640:	e8 99 00 00 00       	call   8016de <cprintf>
  801645:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801648:	cc                   	int3   
  801649:	eb fd                	jmp    801648 <_panic+0x43>

0080164b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	53                   	push   %ebx
  80164f:	83 ec 04             	sub    $0x4,%esp
  801652:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801655:	8b 13                	mov    (%ebx),%edx
  801657:	8d 42 01             	lea    0x1(%edx),%eax
  80165a:	89 03                	mov    %eax,(%ebx)
  80165c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80165f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801663:	3d ff 00 00 00       	cmp    $0xff,%eax
  801668:	75 1a                	jne    801684 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80166a:	83 ec 08             	sub    $0x8,%esp
  80166d:	68 ff 00 00 00       	push   $0xff
  801672:	8d 43 08             	lea    0x8(%ebx),%eax
  801675:	50                   	push   %eax
  801676:	e8 5c ea ff ff       	call   8000d7 <sys_cputs>
		b->idx = 0;
  80167b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801681:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801684:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801696:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80169d:	00 00 00 
	b.cnt = 0;
  8016a0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8016a7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8016aa:	ff 75 0c             	pushl  0xc(%ebp)
  8016ad:	ff 75 08             	pushl  0x8(%ebp)
  8016b0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8016b6:	50                   	push   %eax
  8016b7:	68 4b 16 80 00       	push   $0x80164b
  8016bc:	e8 54 01 00 00       	call   801815 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8016c1:	83 c4 08             	add    $0x8,%esp
  8016c4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8016ca:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8016d0:	50                   	push   %eax
  8016d1:	e8 01 ea ff ff       	call   8000d7 <sys_cputs>

	return b.cnt;
}
  8016d6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016e4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016e7:	50                   	push   %eax
  8016e8:	ff 75 08             	pushl  0x8(%ebp)
  8016eb:	e8 9d ff ff ff       	call   80168d <vcprintf>
	va_end(ap);

	return cnt;
}
  8016f0:	c9                   	leave  
  8016f1:	c3                   	ret    

008016f2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	57                   	push   %edi
  8016f6:	56                   	push   %esi
  8016f7:	53                   	push   %ebx
  8016f8:	83 ec 1c             	sub    $0x1c,%esp
  8016fb:	89 c7                	mov    %eax,%edi
  8016fd:	89 d6                	mov    %edx,%esi
  8016ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801702:	8b 55 0c             	mov    0xc(%ebp),%edx
  801705:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801708:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80170b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80170e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801713:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801716:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801719:	39 d3                	cmp    %edx,%ebx
  80171b:	72 05                	jb     801722 <printnum+0x30>
  80171d:	39 45 10             	cmp    %eax,0x10(%ebp)
  801720:	77 45                	ja     801767 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801722:	83 ec 0c             	sub    $0xc,%esp
  801725:	ff 75 18             	pushl  0x18(%ebp)
  801728:	8b 45 14             	mov    0x14(%ebp),%eax
  80172b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80172e:	53                   	push   %ebx
  80172f:	ff 75 10             	pushl  0x10(%ebp)
  801732:	83 ec 08             	sub    $0x8,%esp
  801735:	ff 75 e4             	pushl  -0x1c(%ebp)
  801738:	ff 75 e0             	pushl  -0x20(%ebp)
  80173b:	ff 75 dc             	pushl  -0x24(%ebp)
  80173e:	ff 75 d8             	pushl  -0x28(%ebp)
  801741:	e8 3a 0a 00 00       	call   802180 <__udivdi3>
  801746:	83 c4 18             	add    $0x18,%esp
  801749:	52                   	push   %edx
  80174a:	50                   	push   %eax
  80174b:	89 f2                	mov    %esi,%edx
  80174d:	89 f8                	mov    %edi,%eax
  80174f:	e8 9e ff ff ff       	call   8016f2 <printnum>
  801754:	83 c4 20             	add    $0x20,%esp
  801757:	eb 18                	jmp    801771 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801759:	83 ec 08             	sub    $0x8,%esp
  80175c:	56                   	push   %esi
  80175d:	ff 75 18             	pushl  0x18(%ebp)
  801760:	ff d7                	call   *%edi
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	eb 03                	jmp    80176a <printnum+0x78>
  801767:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80176a:	83 eb 01             	sub    $0x1,%ebx
  80176d:	85 db                	test   %ebx,%ebx
  80176f:	7f e8                	jg     801759 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801771:	83 ec 08             	sub    $0x8,%esp
  801774:	56                   	push   %esi
  801775:	83 ec 04             	sub    $0x4,%esp
  801778:	ff 75 e4             	pushl  -0x1c(%ebp)
  80177b:	ff 75 e0             	pushl  -0x20(%ebp)
  80177e:	ff 75 dc             	pushl  -0x24(%ebp)
  801781:	ff 75 d8             	pushl  -0x28(%ebp)
  801784:	e8 27 0b 00 00       	call   8022b0 <__umoddi3>
  801789:	83 c4 14             	add    $0x14,%esp
  80178c:	0f be 80 f3 25 80 00 	movsbl 0x8025f3(%eax),%eax
  801793:	50                   	push   %eax
  801794:	ff d7                	call   *%edi
}
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80179c:	5b                   	pop    %ebx
  80179d:	5e                   	pop    %esi
  80179e:	5f                   	pop    %edi
  80179f:	5d                   	pop    %ebp
  8017a0:	c3                   	ret    

008017a1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8017a4:	83 fa 01             	cmp    $0x1,%edx
  8017a7:	7e 0e                	jle    8017b7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8017a9:	8b 10                	mov    (%eax),%edx
  8017ab:	8d 4a 08             	lea    0x8(%edx),%ecx
  8017ae:	89 08                	mov    %ecx,(%eax)
  8017b0:	8b 02                	mov    (%edx),%eax
  8017b2:	8b 52 04             	mov    0x4(%edx),%edx
  8017b5:	eb 22                	jmp    8017d9 <getuint+0x38>
	else if (lflag)
  8017b7:	85 d2                	test   %edx,%edx
  8017b9:	74 10                	je     8017cb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8017bb:	8b 10                	mov    (%eax),%edx
  8017bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017c0:	89 08                	mov    %ecx,(%eax)
  8017c2:	8b 02                	mov    (%edx),%eax
  8017c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c9:	eb 0e                	jmp    8017d9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8017cb:	8b 10                	mov    (%eax),%edx
  8017cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017d0:	89 08                	mov    %ecx,(%eax)
  8017d2:	8b 02                	mov    (%edx),%eax
  8017d4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017d9:	5d                   	pop    %ebp
  8017da:	c3                   	ret    

008017db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017e1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017e5:	8b 10                	mov    (%eax),%edx
  8017e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8017ea:	73 0a                	jae    8017f6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8017ec:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017ef:	89 08                	mov    %ecx,(%eax)
  8017f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f4:	88 02                	mov    %al,(%edx)
}
  8017f6:	5d                   	pop    %ebp
  8017f7:	c3                   	ret    

008017f8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801801:	50                   	push   %eax
  801802:	ff 75 10             	pushl  0x10(%ebp)
  801805:	ff 75 0c             	pushl  0xc(%ebp)
  801808:	ff 75 08             	pushl  0x8(%ebp)
  80180b:	e8 05 00 00 00       	call   801815 <vprintfmt>
	va_end(ap);
}
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	c9                   	leave  
  801814:	c3                   	ret    

00801815 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	57                   	push   %edi
  801819:	56                   	push   %esi
  80181a:	53                   	push   %ebx
  80181b:	83 ec 2c             	sub    $0x2c,%esp
  80181e:	8b 75 08             	mov    0x8(%ebp),%esi
  801821:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801824:	8b 7d 10             	mov    0x10(%ebp),%edi
  801827:	eb 12                	jmp    80183b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801829:	85 c0                	test   %eax,%eax
  80182b:	0f 84 89 03 00 00    	je     801bba <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	53                   	push   %ebx
  801835:	50                   	push   %eax
  801836:	ff d6                	call   *%esi
  801838:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80183b:	83 c7 01             	add    $0x1,%edi
  80183e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801842:	83 f8 25             	cmp    $0x25,%eax
  801845:	75 e2                	jne    801829 <vprintfmt+0x14>
  801847:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80184b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801852:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801859:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801860:	ba 00 00 00 00       	mov    $0x0,%edx
  801865:	eb 07                	jmp    80186e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801867:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80186a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186e:	8d 47 01             	lea    0x1(%edi),%eax
  801871:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801874:	0f b6 07             	movzbl (%edi),%eax
  801877:	0f b6 c8             	movzbl %al,%ecx
  80187a:	83 e8 23             	sub    $0x23,%eax
  80187d:	3c 55                	cmp    $0x55,%al
  80187f:	0f 87 1a 03 00 00    	ja     801b9f <vprintfmt+0x38a>
  801885:	0f b6 c0             	movzbl %al,%eax
  801888:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
  80188f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801892:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801896:	eb d6                	jmp    80186e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801898:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80189b:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8018a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8018a6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8018aa:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8018ad:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8018b0:	83 fa 09             	cmp    $0x9,%edx
  8018b3:	77 39                	ja     8018ee <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8018b5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8018b8:	eb e9                	jmp    8018a3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8018ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8018bd:	8d 48 04             	lea    0x4(%eax),%ecx
  8018c0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8018c3:	8b 00                	mov    (%eax),%eax
  8018c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8018cb:	eb 27                	jmp    8018f4 <vprintfmt+0xdf>
  8018cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018d7:	0f 49 c8             	cmovns %eax,%ecx
  8018da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018e0:	eb 8c                	jmp    80186e <vprintfmt+0x59>
  8018e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018e5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018ec:	eb 80                	jmp    80186e <vprintfmt+0x59>
  8018ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018f1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018f8:	0f 89 70 ff ff ff    	jns    80186e <vprintfmt+0x59>
				width = precision, precision = -1;
  8018fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801901:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801904:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80190b:	e9 5e ff ff ff       	jmp    80186e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801910:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801913:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801916:	e9 53 ff ff ff       	jmp    80186e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80191b:	8b 45 14             	mov    0x14(%ebp),%eax
  80191e:	8d 50 04             	lea    0x4(%eax),%edx
  801921:	89 55 14             	mov    %edx,0x14(%ebp)
  801924:	83 ec 08             	sub    $0x8,%esp
  801927:	53                   	push   %ebx
  801928:	ff 30                	pushl  (%eax)
  80192a:	ff d6                	call   *%esi
			break;
  80192c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801932:	e9 04 ff ff ff       	jmp    80183b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801937:	8b 45 14             	mov    0x14(%ebp),%eax
  80193a:	8d 50 04             	lea    0x4(%eax),%edx
  80193d:	89 55 14             	mov    %edx,0x14(%ebp)
  801940:	8b 00                	mov    (%eax),%eax
  801942:	99                   	cltd   
  801943:	31 d0                	xor    %edx,%eax
  801945:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801947:	83 f8 0f             	cmp    $0xf,%eax
  80194a:	7f 0b                	jg     801957 <vprintfmt+0x142>
  80194c:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  801953:	85 d2                	test   %edx,%edx
  801955:	75 18                	jne    80196f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801957:	50                   	push   %eax
  801958:	68 0b 26 80 00       	push   $0x80260b
  80195d:	53                   	push   %ebx
  80195e:	56                   	push   %esi
  80195f:	e8 94 fe ff ff       	call   8017f8 <printfmt>
  801964:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801967:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80196a:	e9 cc fe ff ff       	jmp    80183b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80196f:	52                   	push   %edx
  801970:	68 89 25 80 00       	push   $0x802589
  801975:	53                   	push   %ebx
  801976:	56                   	push   %esi
  801977:	e8 7c fe ff ff       	call   8017f8 <printfmt>
  80197c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80197f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801982:	e9 b4 fe ff ff       	jmp    80183b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801987:	8b 45 14             	mov    0x14(%ebp),%eax
  80198a:	8d 50 04             	lea    0x4(%eax),%edx
  80198d:	89 55 14             	mov    %edx,0x14(%ebp)
  801990:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801992:	85 ff                	test   %edi,%edi
  801994:	b8 04 26 80 00       	mov    $0x802604,%eax
  801999:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80199c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8019a0:	0f 8e 94 00 00 00    	jle    801a3a <vprintfmt+0x225>
  8019a6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8019aa:	0f 84 98 00 00 00    	je     801a48 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8019b0:	83 ec 08             	sub    $0x8,%esp
  8019b3:	ff 75 d0             	pushl  -0x30(%ebp)
  8019b6:	57                   	push   %edi
  8019b7:	e8 86 02 00 00       	call   801c42 <strnlen>
  8019bc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8019bf:	29 c1                	sub    %eax,%ecx
  8019c1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8019c4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8019c7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8019cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019ce:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8019d1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019d3:	eb 0f                	jmp    8019e4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8019d5:	83 ec 08             	sub    $0x8,%esp
  8019d8:	53                   	push   %ebx
  8019d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8019dc:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019de:	83 ef 01             	sub    $0x1,%edi
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	85 ff                	test   %edi,%edi
  8019e6:	7f ed                	jg     8019d5 <vprintfmt+0x1c0>
  8019e8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019eb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019ee:	85 c9                	test   %ecx,%ecx
  8019f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f5:	0f 49 c1             	cmovns %ecx,%eax
  8019f8:	29 c1                	sub    %eax,%ecx
  8019fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8019fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a00:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a03:	89 cb                	mov    %ecx,%ebx
  801a05:	eb 4d                	jmp    801a54 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a07:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a0b:	74 1b                	je     801a28 <vprintfmt+0x213>
  801a0d:	0f be c0             	movsbl %al,%eax
  801a10:	83 e8 20             	sub    $0x20,%eax
  801a13:	83 f8 5e             	cmp    $0x5e,%eax
  801a16:	76 10                	jbe    801a28 <vprintfmt+0x213>
					putch('?', putdat);
  801a18:	83 ec 08             	sub    $0x8,%esp
  801a1b:	ff 75 0c             	pushl  0xc(%ebp)
  801a1e:	6a 3f                	push   $0x3f
  801a20:	ff 55 08             	call   *0x8(%ebp)
  801a23:	83 c4 10             	add    $0x10,%esp
  801a26:	eb 0d                	jmp    801a35 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801a28:	83 ec 08             	sub    $0x8,%esp
  801a2b:	ff 75 0c             	pushl  0xc(%ebp)
  801a2e:	52                   	push   %edx
  801a2f:	ff 55 08             	call   *0x8(%ebp)
  801a32:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a35:	83 eb 01             	sub    $0x1,%ebx
  801a38:	eb 1a                	jmp    801a54 <vprintfmt+0x23f>
  801a3a:	89 75 08             	mov    %esi,0x8(%ebp)
  801a3d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a40:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a43:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a46:	eb 0c                	jmp    801a54 <vprintfmt+0x23f>
  801a48:	89 75 08             	mov    %esi,0x8(%ebp)
  801a4b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a4e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a51:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a54:	83 c7 01             	add    $0x1,%edi
  801a57:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a5b:	0f be d0             	movsbl %al,%edx
  801a5e:	85 d2                	test   %edx,%edx
  801a60:	74 23                	je     801a85 <vprintfmt+0x270>
  801a62:	85 f6                	test   %esi,%esi
  801a64:	78 a1                	js     801a07 <vprintfmt+0x1f2>
  801a66:	83 ee 01             	sub    $0x1,%esi
  801a69:	79 9c                	jns    801a07 <vprintfmt+0x1f2>
  801a6b:	89 df                	mov    %ebx,%edi
  801a6d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a73:	eb 18                	jmp    801a8d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a75:	83 ec 08             	sub    $0x8,%esp
  801a78:	53                   	push   %ebx
  801a79:	6a 20                	push   $0x20
  801a7b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a7d:	83 ef 01             	sub    $0x1,%edi
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	eb 08                	jmp    801a8d <vprintfmt+0x278>
  801a85:	89 df                	mov    %ebx,%edi
  801a87:	8b 75 08             	mov    0x8(%ebp),%esi
  801a8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a8d:	85 ff                	test   %edi,%edi
  801a8f:	7f e4                	jg     801a75 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a91:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a94:	e9 a2 fd ff ff       	jmp    80183b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a99:	83 fa 01             	cmp    $0x1,%edx
  801a9c:	7e 16                	jle    801ab4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a9e:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa1:	8d 50 08             	lea    0x8(%eax),%edx
  801aa4:	89 55 14             	mov    %edx,0x14(%ebp)
  801aa7:	8b 50 04             	mov    0x4(%eax),%edx
  801aaa:	8b 00                	mov    (%eax),%eax
  801aac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aaf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801ab2:	eb 32                	jmp    801ae6 <vprintfmt+0x2d1>
	else if (lflag)
  801ab4:	85 d2                	test   %edx,%edx
  801ab6:	74 18                	je     801ad0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801ab8:	8b 45 14             	mov    0x14(%ebp),%eax
  801abb:	8d 50 04             	lea    0x4(%eax),%edx
  801abe:	89 55 14             	mov    %edx,0x14(%ebp)
  801ac1:	8b 00                	mov    (%eax),%eax
  801ac3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ac6:	89 c1                	mov    %eax,%ecx
  801ac8:	c1 f9 1f             	sar    $0x1f,%ecx
  801acb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801ace:	eb 16                	jmp    801ae6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801ad0:	8b 45 14             	mov    0x14(%ebp),%eax
  801ad3:	8d 50 04             	lea    0x4(%eax),%edx
  801ad6:	89 55 14             	mov    %edx,0x14(%ebp)
  801ad9:	8b 00                	mov    (%eax),%eax
  801adb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ade:	89 c1                	mov    %eax,%ecx
  801ae0:	c1 f9 1f             	sar    $0x1f,%ecx
  801ae3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ae6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ae9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801aec:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801af1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801af5:	79 74                	jns    801b6b <vprintfmt+0x356>
				putch('-', putdat);
  801af7:	83 ec 08             	sub    $0x8,%esp
  801afa:	53                   	push   %ebx
  801afb:	6a 2d                	push   $0x2d
  801afd:	ff d6                	call   *%esi
				num = -(long long) num;
  801aff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b02:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b05:	f7 d8                	neg    %eax
  801b07:	83 d2 00             	adc    $0x0,%edx
  801b0a:	f7 da                	neg    %edx
  801b0c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801b0f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801b14:	eb 55                	jmp    801b6b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b16:	8d 45 14             	lea    0x14(%ebp),%eax
  801b19:	e8 83 fc ff ff       	call   8017a1 <getuint>
			base = 10;
  801b1e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801b23:	eb 46                	jmp    801b6b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801b25:	8d 45 14             	lea    0x14(%ebp),%eax
  801b28:	e8 74 fc ff ff       	call   8017a1 <getuint>
			base = 8;
  801b2d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b32:	eb 37                	jmp    801b6b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b34:	83 ec 08             	sub    $0x8,%esp
  801b37:	53                   	push   %ebx
  801b38:	6a 30                	push   $0x30
  801b3a:	ff d6                	call   *%esi
			putch('x', putdat);
  801b3c:	83 c4 08             	add    $0x8,%esp
  801b3f:	53                   	push   %ebx
  801b40:	6a 78                	push   $0x78
  801b42:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b44:	8b 45 14             	mov    0x14(%ebp),%eax
  801b47:	8d 50 04             	lea    0x4(%eax),%edx
  801b4a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b4d:	8b 00                	mov    (%eax),%eax
  801b4f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b54:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b57:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b5c:	eb 0d                	jmp    801b6b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b5e:	8d 45 14             	lea    0x14(%ebp),%eax
  801b61:	e8 3b fc ff ff       	call   8017a1 <getuint>
			base = 16;
  801b66:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b6b:	83 ec 0c             	sub    $0xc,%esp
  801b6e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b72:	57                   	push   %edi
  801b73:	ff 75 e0             	pushl  -0x20(%ebp)
  801b76:	51                   	push   %ecx
  801b77:	52                   	push   %edx
  801b78:	50                   	push   %eax
  801b79:	89 da                	mov    %ebx,%edx
  801b7b:	89 f0                	mov    %esi,%eax
  801b7d:	e8 70 fb ff ff       	call   8016f2 <printnum>
			break;
  801b82:	83 c4 20             	add    $0x20,%esp
  801b85:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b88:	e9 ae fc ff ff       	jmp    80183b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b8d:	83 ec 08             	sub    $0x8,%esp
  801b90:	53                   	push   %ebx
  801b91:	51                   	push   %ecx
  801b92:	ff d6                	call   *%esi
			break;
  801b94:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b9a:	e9 9c fc ff ff       	jmp    80183b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b9f:	83 ec 08             	sub    $0x8,%esp
  801ba2:	53                   	push   %ebx
  801ba3:	6a 25                	push   $0x25
  801ba5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	eb 03                	jmp    801baf <vprintfmt+0x39a>
  801bac:	83 ef 01             	sub    $0x1,%edi
  801baf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801bb3:	75 f7                	jne    801bac <vprintfmt+0x397>
  801bb5:	e9 81 fc ff ff       	jmp    80183b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5f                   	pop    %edi
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    

00801bc2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	83 ec 18             	sub    $0x18,%esp
  801bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801bce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801bd1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801bd5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801bd8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801bdf:	85 c0                	test   %eax,%eax
  801be1:	74 26                	je     801c09 <vsnprintf+0x47>
  801be3:	85 d2                	test   %edx,%edx
  801be5:	7e 22                	jle    801c09 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801be7:	ff 75 14             	pushl  0x14(%ebp)
  801bea:	ff 75 10             	pushl  0x10(%ebp)
  801bed:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bf0:	50                   	push   %eax
  801bf1:	68 db 17 80 00       	push   $0x8017db
  801bf6:	e8 1a fc ff ff       	call   801815 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bfe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	eb 05                	jmp    801c0e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c09:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801c0e:	c9                   	leave  
  801c0f:	c3                   	ret    

00801c10 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c16:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c19:	50                   	push   %eax
  801c1a:	ff 75 10             	pushl  0x10(%ebp)
  801c1d:	ff 75 0c             	pushl  0xc(%ebp)
  801c20:	ff 75 08             	pushl  0x8(%ebp)
  801c23:	e8 9a ff ff ff       	call   801bc2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801c28:	c9                   	leave  
  801c29:	c3                   	ret    

00801c2a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c30:	b8 00 00 00 00       	mov    $0x0,%eax
  801c35:	eb 03                	jmp    801c3a <strlen+0x10>
		n++;
  801c37:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c3a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c3e:	75 f7                	jne    801c37 <strlen+0xd>
		n++;
	return n;
}
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c48:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c50:	eb 03                	jmp    801c55 <strnlen+0x13>
		n++;
  801c52:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c55:	39 c2                	cmp    %eax,%edx
  801c57:	74 08                	je     801c61 <strnlen+0x1f>
  801c59:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c5d:	75 f3                	jne    801c52 <strnlen+0x10>
  801c5f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c61:	5d                   	pop    %ebp
  801c62:	c3                   	ret    

00801c63 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	53                   	push   %ebx
  801c67:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c6d:	89 c2                	mov    %eax,%edx
  801c6f:	83 c2 01             	add    $0x1,%edx
  801c72:	83 c1 01             	add    $0x1,%ecx
  801c75:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c79:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c7c:	84 db                	test   %bl,%bl
  801c7e:	75 ef                	jne    801c6f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c80:	5b                   	pop    %ebx
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    

00801c83 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	53                   	push   %ebx
  801c87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c8a:	53                   	push   %ebx
  801c8b:	e8 9a ff ff ff       	call   801c2a <strlen>
  801c90:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c93:	ff 75 0c             	pushl  0xc(%ebp)
  801c96:	01 d8                	add    %ebx,%eax
  801c98:	50                   	push   %eax
  801c99:	e8 c5 ff ff ff       	call   801c63 <strcpy>
	return dst;
}
  801c9e:	89 d8                	mov    %ebx,%eax
  801ca0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca3:	c9                   	leave  
  801ca4:	c3                   	ret    

00801ca5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	56                   	push   %esi
  801ca9:	53                   	push   %ebx
  801caa:	8b 75 08             	mov    0x8(%ebp),%esi
  801cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cb0:	89 f3                	mov    %esi,%ebx
  801cb2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801cb5:	89 f2                	mov    %esi,%edx
  801cb7:	eb 0f                	jmp    801cc8 <strncpy+0x23>
		*dst++ = *src;
  801cb9:	83 c2 01             	add    $0x1,%edx
  801cbc:	0f b6 01             	movzbl (%ecx),%eax
  801cbf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801cc2:	80 39 01             	cmpb   $0x1,(%ecx)
  801cc5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801cc8:	39 da                	cmp    %ebx,%edx
  801cca:	75 ed                	jne    801cb9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ccc:	89 f0                	mov    %esi,%eax
  801cce:	5b                   	pop    %ebx
  801ccf:	5e                   	pop    %esi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    

00801cd2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	56                   	push   %esi
  801cd6:	53                   	push   %ebx
  801cd7:	8b 75 08             	mov    0x8(%ebp),%esi
  801cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cdd:	8b 55 10             	mov    0x10(%ebp),%edx
  801ce0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ce2:	85 d2                	test   %edx,%edx
  801ce4:	74 21                	je     801d07 <strlcpy+0x35>
  801ce6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801cea:	89 f2                	mov    %esi,%edx
  801cec:	eb 09                	jmp    801cf7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801cee:	83 c2 01             	add    $0x1,%edx
  801cf1:	83 c1 01             	add    $0x1,%ecx
  801cf4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801cf7:	39 c2                	cmp    %eax,%edx
  801cf9:	74 09                	je     801d04 <strlcpy+0x32>
  801cfb:	0f b6 19             	movzbl (%ecx),%ebx
  801cfe:	84 db                	test   %bl,%bl
  801d00:	75 ec                	jne    801cee <strlcpy+0x1c>
  801d02:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801d04:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801d07:	29 f0                	sub    %esi,%eax
}
  801d09:	5b                   	pop    %ebx
  801d0a:	5e                   	pop    %esi
  801d0b:	5d                   	pop    %ebp
  801d0c:	c3                   	ret    

00801d0d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801d0d:	55                   	push   %ebp
  801d0e:	89 e5                	mov    %esp,%ebp
  801d10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d13:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801d16:	eb 06                	jmp    801d1e <strcmp+0x11>
		p++, q++;
  801d18:	83 c1 01             	add    $0x1,%ecx
  801d1b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801d1e:	0f b6 01             	movzbl (%ecx),%eax
  801d21:	84 c0                	test   %al,%al
  801d23:	74 04                	je     801d29 <strcmp+0x1c>
  801d25:	3a 02                	cmp    (%edx),%al
  801d27:	74 ef                	je     801d18 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801d29:	0f b6 c0             	movzbl %al,%eax
  801d2c:	0f b6 12             	movzbl (%edx),%edx
  801d2f:	29 d0                	sub    %edx,%eax
}
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    

00801d33 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	53                   	push   %ebx
  801d37:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d3d:	89 c3                	mov    %eax,%ebx
  801d3f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d42:	eb 06                	jmp    801d4a <strncmp+0x17>
		n--, p++, q++;
  801d44:	83 c0 01             	add    $0x1,%eax
  801d47:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d4a:	39 d8                	cmp    %ebx,%eax
  801d4c:	74 15                	je     801d63 <strncmp+0x30>
  801d4e:	0f b6 08             	movzbl (%eax),%ecx
  801d51:	84 c9                	test   %cl,%cl
  801d53:	74 04                	je     801d59 <strncmp+0x26>
  801d55:	3a 0a                	cmp    (%edx),%cl
  801d57:	74 eb                	je     801d44 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d59:	0f b6 00             	movzbl (%eax),%eax
  801d5c:	0f b6 12             	movzbl (%edx),%edx
  801d5f:	29 d0                	sub    %edx,%eax
  801d61:	eb 05                	jmp    801d68 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d63:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d68:	5b                   	pop    %ebx
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d75:	eb 07                	jmp    801d7e <strchr+0x13>
		if (*s == c)
  801d77:	38 ca                	cmp    %cl,%dl
  801d79:	74 0f                	je     801d8a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d7b:	83 c0 01             	add    $0x1,%eax
  801d7e:	0f b6 10             	movzbl (%eax),%edx
  801d81:	84 d2                	test   %dl,%dl
  801d83:	75 f2                	jne    801d77 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d92:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d96:	eb 03                	jmp    801d9b <strfind+0xf>
  801d98:	83 c0 01             	add    $0x1,%eax
  801d9b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d9e:	38 ca                	cmp    %cl,%dl
  801da0:	74 04                	je     801da6 <strfind+0x1a>
  801da2:	84 d2                	test   %dl,%dl
  801da4:	75 f2                	jne    801d98 <strfind+0xc>
			break;
	return (char *) s;
}
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    

00801da8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	57                   	push   %edi
  801dac:	56                   	push   %esi
  801dad:	53                   	push   %ebx
  801dae:	8b 7d 08             	mov    0x8(%ebp),%edi
  801db1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801db4:	85 c9                	test   %ecx,%ecx
  801db6:	74 36                	je     801dee <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801db8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801dbe:	75 28                	jne    801de8 <memset+0x40>
  801dc0:	f6 c1 03             	test   $0x3,%cl
  801dc3:	75 23                	jne    801de8 <memset+0x40>
		c &= 0xFF;
  801dc5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801dc9:	89 d3                	mov    %edx,%ebx
  801dcb:	c1 e3 08             	shl    $0x8,%ebx
  801dce:	89 d6                	mov    %edx,%esi
  801dd0:	c1 e6 18             	shl    $0x18,%esi
  801dd3:	89 d0                	mov    %edx,%eax
  801dd5:	c1 e0 10             	shl    $0x10,%eax
  801dd8:	09 f0                	or     %esi,%eax
  801dda:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801ddc:	89 d8                	mov    %ebx,%eax
  801dde:	09 d0                	or     %edx,%eax
  801de0:	c1 e9 02             	shr    $0x2,%ecx
  801de3:	fc                   	cld    
  801de4:	f3 ab                	rep stos %eax,%es:(%edi)
  801de6:	eb 06                	jmp    801dee <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801de8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801deb:	fc                   	cld    
  801dec:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801dee:	89 f8                	mov    %edi,%eax
  801df0:	5b                   	pop    %ebx
  801df1:	5e                   	pop    %esi
  801df2:	5f                   	pop    %edi
  801df3:	5d                   	pop    %ebp
  801df4:	c3                   	ret    

00801df5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	57                   	push   %edi
  801df9:	56                   	push   %esi
  801dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e03:	39 c6                	cmp    %eax,%esi
  801e05:	73 35                	jae    801e3c <memmove+0x47>
  801e07:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e0a:	39 d0                	cmp    %edx,%eax
  801e0c:	73 2e                	jae    801e3c <memmove+0x47>
		s += n;
		d += n;
  801e0e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e11:	89 d6                	mov    %edx,%esi
  801e13:	09 fe                	or     %edi,%esi
  801e15:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e1b:	75 13                	jne    801e30 <memmove+0x3b>
  801e1d:	f6 c1 03             	test   $0x3,%cl
  801e20:	75 0e                	jne    801e30 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801e22:	83 ef 04             	sub    $0x4,%edi
  801e25:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e28:	c1 e9 02             	shr    $0x2,%ecx
  801e2b:	fd                   	std    
  801e2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e2e:	eb 09                	jmp    801e39 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e30:	83 ef 01             	sub    $0x1,%edi
  801e33:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e36:	fd                   	std    
  801e37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e39:	fc                   	cld    
  801e3a:	eb 1d                	jmp    801e59 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e3c:	89 f2                	mov    %esi,%edx
  801e3e:	09 c2                	or     %eax,%edx
  801e40:	f6 c2 03             	test   $0x3,%dl
  801e43:	75 0f                	jne    801e54 <memmove+0x5f>
  801e45:	f6 c1 03             	test   $0x3,%cl
  801e48:	75 0a                	jne    801e54 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e4a:	c1 e9 02             	shr    $0x2,%ecx
  801e4d:	89 c7                	mov    %eax,%edi
  801e4f:	fc                   	cld    
  801e50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e52:	eb 05                	jmp    801e59 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e54:	89 c7                	mov    %eax,%edi
  801e56:	fc                   	cld    
  801e57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e59:	5e                   	pop    %esi
  801e5a:	5f                   	pop    %edi
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    

00801e5d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e60:	ff 75 10             	pushl  0x10(%ebp)
  801e63:	ff 75 0c             	pushl  0xc(%ebp)
  801e66:	ff 75 08             	pushl  0x8(%ebp)
  801e69:	e8 87 ff ff ff       	call   801df5 <memmove>
}
  801e6e:	c9                   	leave  
  801e6f:	c3                   	ret    

00801e70 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	56                   	push   %esi
  801e74:	53                   	push   %ebx
  801e75:	8b 45 08             	mov    0x8(%ebp),%eax
  801e78:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e7b:	89 c6                	mov    %eax,%esi
  801e7d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e80:	eb 1a                	jmp    801e9c <memcmp+0x2c>
		if (*s1 != *s2)
  801e82:	0f b6 08             	movzbl (%eax),%ecx
  801e85:	0f b6 1a             	movzbl (%edx),%ebx
  801e88:	38 d9                	cmp    %bl,%cl
  801e8a:	74 0a                	je     801e96 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e8c:	0f b6 c1             	movzbl %cl,%eax
  801e8f:	0f b6 db             	movzbl %bl,%ebx
  801e92:	29 d8                	sub    %ebx,%eax
  801e94:	eb 0f                	jmp    801ea5 <memcmp+0x35>
		s1++, s2++;
  801e96:	83 c0 01             	add    $0x1,%eax
  801e99:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e9c:	39 f0                	cmp    %esi,%eax
  801e9e:	75 e2                	jne    801e82 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801ea0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ea5:	5b                   	pop    %ebx
  801ea6:	5e                   	pop    %esi
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    

00801ea9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	53                   	push   %ebx
  801ead:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801eb0:	89 c1                	mov    %eax,%ecx
  801eb2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801eb5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801eb9:	eb 0a                	jmp    801ec5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ebb:	0f b6 10             	movzbl (%eax),%edx
  801ebe:	39 da                	cmp    %ebx,%edx
  801ec0:	74 07                	je     801ec9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ec2:	83 c0 01             	add    $0x1,%eax
  801ec5:	39 c8                	cmp    %ecx,%eax
  801ec7:	72 f2                	jb     801ebb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801ec9:	5b                   	pop    %ebx
  801eca:	5d                   	pop    %ebp
  801ecb:	c3                   	ret    

00801ecc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	57                   	push   %edi
  801ed0:	56                   	push   %esi
  801ed1:	53                   	push   %ebx
  801ed2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ed8:	eb 03                	jmp    801edd <strtol+0x11>
		s++;
  801eda:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801edd:	0f b6 01             	movzbl (%ecx),%eax
  801ee0:	3c 20                	cmp    $0x20,%al
  801ee2:	74 f6                	je     801eda <strtol+0xe>
  801ee4:	3c 09                	cmp    $0x9,%al
  801ee6:	74 f2                	je     801eda <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ee8:	3c 2b                	cmp    $0x2b,%al
  801eea:	75 0a                	jne    801ef6 <strtol+0x2a>
		s++;
  801eec:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801eef:	bf 00 00 00 00       	mov    $0x0,%edi
  801ef4:	eb 11                	jmp    801f07 <strtol+0x3b>
  801ef6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801efb:	3c 2d                	cmp    $0x2d,%al
  801efd:	75 08                	jne    801f07 <strtol+0x3b>
		s++, neg = 1;
  801eff:	83 c1 01             	add    $0x1,%ecx
  801f02:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f07:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f0d:	75 15                	jne    801f24 <strtol+0x58>
  801f0f:	80 39 30             	cmpb   $0x30,(%ecx)
  801f12:	75 10                	jne    801f24 <strtol+0x58>
  801f14:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f18:	75 7c                	jne    801f96 <strtol+0xca>
		s += 2, base = 16;
  801f1a:	83 c1 02             	add    $0x2,%ecx
  801f1d:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f22:	eb 16                	jmp    801f3a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801f24:	85 db                	test   %ebx,%ebx
  801f26:	75 12                	jne    801f3a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f28:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f2d:	80 39 30             	cmpb   $0x30,(%ecx)
  801f30:	75 08                	jne    801f3a <strtol+0x6e>
		s++, base = 8;
  801f32:	83 c1 01             	add    $0x1,%ecx
  801f35:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f42:	0f b6 11             	movzbl (%ecx),%edx
  801f45:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f48:	89 f3                	mov    %esi,%ebx
  801f4a:	80 fb 09             	cmp    $0x9,%bl
  801f4d:	77 08                	ja     801f57 <strtol+0x8b>
			dig = *s - '0';
  801f4f:	0f be d2             	movsbl %dl,%edx
  801f52:	83 ea 30             	sub    $0x30,%edx
  801f55:	eb 22                	jmp    801f79 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f57:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f5a:	89 f3                	mov    %esi,%ebx
  801f5c:	80 fb 19             	cmp    $0x19,%bl
  801f5f:	77 08                	ja     801f69 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f61:	0f be d2             	movsbl %dl,%edx
  801f64:	83 ea 57             	sub    $0x57,%edx
  801f67:	eb 10                	jmp    801f79 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f69:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f6c:	89 f3                	mov    %esi,%ebx
  801f6e:	80 fb 19             	cmp    $0x19,%bl
  801f71:	77 16                	ja     801f89 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f73:	0f be d2             	movsbl %dl,%edx
  801f76:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f79:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f7c:	7d 0b                	jge    801f89 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f7e:	83 c1 01             	add    $0x1,%ecx
  801f81:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f85:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f87:	eb b9                	jmp    801f42 <strtol+0x76>

	if (endptr)
  801f89:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f8d:	74 0d                	je     801f9c <strtol+0xd0>
		*endptr = (char *) s;
  801f8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f92:	89 0e                	mov    %ecx,(%esi)
  801f94:	eb 06                	jmp    801f9c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f96:	85 db                	test   %ebx,%ebx
  801f98:	74 98                	je     801f32 <strtol+0x66>
  801f9a:	eb 9e                	jmp    801f3a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f9c:	89 c2                	mov    %eax,%edx
  801f9e:	f7 da                	neg    %edx
  801fa0:	85 ff                	test   %edi,%edi
  801fa2:	0f 45 c2             	cmovne %edx,%eax
}
  801fa5:	5b                   	pop    %ebx
  801fa6:	5e                   	pop    %esi
  801fa7:	5f                   	pop    %edi
  801fa8:	5d                   	pop    %ebp
  801fa9:	c3                   	ret    

00801faa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fb0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fb7:	75 2a                	jne    801fe3 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801fb9:	83 ec 04             	sub    $0x4,%esp
  801fbc:	6a 07                	push   $0x7
  801fbe:	68 00 f0 bf ee       	push   $0xeebff000
  801fc3:	6a 00                	push   $0x0
  801fc5:	e8 c9 e1 ff ff       	call   800193 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fca:	83 c4 10             	add    $0x10,%esp
  801fcd:	85 c0                	test   %eax,%eax
  801fcf:	79 12                	jns    801fe3 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fd1:	50                   	push   %eax
  801fd2:	68 dd 24 80 00       	push   $0x8024dd
  801fd7:	6a 23                	push   $0x23
  801fd9:	68 00 29 80 00       	push   $0x802900
  801fde:	e8 22 f6 ff ff       	call   801605 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe6:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801feb:	83 ec 08             	sub    $0x8,%esp
  801fee:	68 e4 03 80 00       	push   $0x8003e4
  801ff3:	6a 00                	push   $0x0
  801ff5:	e8 e4 e2 ff ff       	call   8002de <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	79 12                	jns    802013 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802001:	50                   	push   %eax
  802002:	68 dd 24 80 00       	push   $0x8024dd
  802007:	6a 2c                	push   $0x2c
  802009:	68 00 29 80 00       	push   $0x802900
  80200e:	e8 f2 f5 ff ff       	call   801605 <_panic>
	}
}
  802013:	c9                   	leave  
  802014:	c3                   	ret    

00802015 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802015:	55                   	push   %ebp
  802016:	89 e5                	mov    %esp,%ebp
  802018:	56                   	push   %esi
  802019:	53                   	push   %ebx
  80201a:	8b 75 08             	mov    0x8(%ebp),%esi
  80201d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802020:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802023:	85 c0                	test   %eax,%eax
  802025:	75 12                	jne    802039 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802027:	83 ec 0c             	sub    $0xc,%esp
  80202a:	68 00 00 c0 ee       	push   $0xeec00000
  80202f:	e8 0f e3 ff ff       	call   800343 <sys_ipc_recv>
  802034:	83 c4 10             	add    $0x10,%esp
  802037:	eb 0c                	jmp    802045 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802039:	83 ec 0c             	sub    $0xc,%esp
  80203c:	50                   	push   %eax
  80203d:	e8 01 e3 ff ff       	call   800343 <sys_ipc_recv>
  802042:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802045:	85 f6                	test   %esi,%esi
  802047:	0f 95 c1             	setne  %cl
  80204a:	85 db                	test   %ebx,%ebx
  80204c:	0f 95 c2             	setne  %dl
  80204f:	84 d1                	test   %dl,%cl
  802051:	74 09                	je     80205c <ipc_recv+0x47>
  802053:	89 c2                	mov    %eax,%edx
  802055:	c1 ea 1f             	shr    $0x1f,%edx
  802058:	84 d2                	test   %dl,%dl
  80205a:	75 2d                	jne    802089 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80205c:	85 f6                	test   %esi,%esi
  80205e:	74 0d                	je     80206d <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802060:	a1 04 40 80 00       	mov    0x804004,%eax
  802065:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  80206b:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80206d:	85 db                	test   %ebx,%ebx
  80206f:	74 0d                	je     80207e <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802071:	a1 04 40 80 00       	mov    0x804004,%eax
  802076:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80207c:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80207e:	a1 04 40 80 00       	mov    0x804004,%eax
  802083:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80208c:	5b                   	pop    %ebx
  80208d:	5e                   	pop    %esi
  80208e:	5d                   	pop    %ebp
  80208f:	c3                   	ret    

00802090 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	57                   	push   %edi
  802094:	56                   	push   %esi
  802095:	53                   	push   %ebx
  802096:	83 ec 0c             	sub    $0xc,%esp
  802099:	8b 7d 08             	mov    0x8(%ebp),%edi
  80209c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80209f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020a2:	85 db                	test   %ebx,%ebx
  8020a4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020a9:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020ac:	ff 75 14             	pushl  0x14(%ebp)
  8020af:	53                   	push   %ebx
  8020b0:	56                   	push   %esi
  8020b1:	57                   	push   %edi
  8020b2:	e8 69 e2 ff ff       	call   800320 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020b7:	89 c2                	mov    %eax,%edx
  8020b9:	c1 ea 1f             	shr    $0x1f,%edx
  8020bc:	83 c4 10             	add    $0x10,%esp
  8020bf:	84 d2                	test   %dl,%dl
  8020c1:	74 17                	je     8020da <ipc_send+0x4a>
  8020c3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020c6:	74 12                	je     8020da <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020c8:	50                   	push   %eax
  8020c9:	68 0e 29 80 00       	push   $0x80290e
  8020ce:	6a 47                	push   $0x47
  8020d0:	68 1c 29 80 00       	push   $0x80291c
  8020d5:	e8 2b f5 ff ff       	call   801605 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020da:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020dd:	75 07                	jne    8020e6 <ipc_send+0x56>
			sys_yield();
  8020df:	e8 90 e0 ff ff       	call   800174 <sys_yield>
  8020e4:	eb c6                	jmp    8020ac <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020e6:	85 c0                	test   %eax,%eax
  8020e8:	75 c2                	jne    8020ac <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    

008020f2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020f2:	55                   	push   %ebp
  8020f3:	89 e5                	mov    %esp,%ebp
  8020f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020f8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020fd:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802103:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802109:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  80210f:	39 ca                	cmp    %ecx,%edx
  802111:	75 13                	jne    802126 <ipc_find_env+0x34>
			return envs[i].env_id;
  802113:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802119:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80211e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802124:	eb 0f                	jmp    802135 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802126:	83 c0 01             	add    $0x1,%eax
  802129:	3d 00 04 00 00       	cmp    $0x400,%eax
  80212e:	75 cd                	jne    8020fd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802130:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802135:	5d                   	pop    %ebp
  802136:	c3                   	ret    

00802137 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802137:	55                   	push   %ebp
  802138:	89 e5                	mov    %esp,%ebp
  80213a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80213d:	89 d0                	mov    %edx,%eax
  80213f:	c1 e8 16             	shr    $0x16,%eax
  802142:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802149:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80214e:	f6 c1 01             	test   $0x1,%cl
  802151:	74 1d                	je     802170 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802153:	c1 ea 0c             	shr    $0xc,%edx
  802156:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80215d:	f6 c2 01             	test   $0x1,%dl
  802160:	74 0e                	je     802170 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802162:	c1 ea 0c             	shr    $0xc,%edx
  802165:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80216c:	ef 
  80216d:	0f b7 c0             	movzwl %ax,%eax
}
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    
  802172:	66 90                	xchg   %ax,%ax
  802174:	66 90                	xchg   %ax,%ax
  802176:	66 90                	xchg   %ax,%ax
  802178:	66 90                	xchg   %ax,%ax
  80217a:	66 90                	xchg   %ax,%ax
  80217c:	66 90                	xchg   %ax,%ax
  80217e:	66 90                	xchg   %ax,%ax

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
