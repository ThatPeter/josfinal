
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
  8000c3:	e8 08 0a 00 00       	call   800ad0 <close_all>
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
  80013c:	68 0a 24 80 00       	push   $0x80240a
  800141:	6a 23                	push   $0x23
  800143:	68 27 24 80 00       	push   $0x802427
  800148:	e8 b4 14 00 00       	call   801601 <_panic>

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
  8001bd:	68 0a 24 80 00       	push   $0x80240a
  8001c2:	6a 23                	push   $0x23
  8001c4:	68 27 24 80 00       	push   $0x802427
  8001c9:	e8 33 14 00 00       	call   801601 <_panic>

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
  8001ff:	68 0a 24 80 00       	push   $0x80240a
  800204:	6a 23                	push   $0x23
  800206:	68 27 24 80 00       	push   $0x802427
  80020b:	e8 f1 13 00 00       	call   801601 <_panic>

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
  800241:	68 0a 24 80 00       	push   $0x80240a
  800246:	6a 23                	push   $0x23
  800248:	68 27 24 80 00       	push   $0x802427
  80024d:	e8 af 13 00 00       	call   801601 <_panic>

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
  800283:	68 0a 24 80 00       	push   $0x80240a
  800288:	6a 23                	push   $0x23
  80028a:	68 27 24 80 00       	push   $0x802427
  80028f:	e8 6d 13 00 00       	call   801601 <_panic>

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
  8002c5:	68 0a 24 80 00       	push   $0x80240a
  8002ca:	6a 23                	push   $0x23
  8002cc:	68 27 24 80 00       	push   $0x802427
  8002d1:	e8 2b 13 00 00       	call   801601 <_panic>
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
  800307:	68 0a 24 80 00       	push   $0x80240a
  80030c:	6a 23                	push   $0x23
  80030e:	68 27 24 80 00       	push   $0x802427
  800313:	e8 e9 12 00 00       	call   801601 <_panic>

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
  80036b:	68 0a 24 80 00       	push   $0x80240a
  800370:	6a 23                	push   $0x23
  800372:	68 27 24 80 00       	push   $0x802427
  800377:	e8 85 12 00 00       	call   801601 <_panic>

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
  80042e:	68 35 24 80 00       	push   $0x802435
  800433:	6a 1f                	push   $0x1f
  800435:	68 45 24 80 00       	push   $0x802445
  80043a:	e8 c2 11 00 00       	call   801601 <_panic>
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
  800458:	68 50 24 80 00       	push   $0x802450
  80045d:	6a 2d                	push   $0x2d
  80045f:	68 45 24 80 00       	push   $0x802445
  800464:	e8 98 11 00 00       	call   801601 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800469:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	68 00 10 00 00       	push   $0x1000
  800477:	53                   	push   %ebx
  800478:	68 00 f0 7f 00       	push   $0x7ff000
  80047d:	e8 d7 19 00 00       	call   801e59 <memcpy>

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
  8004a0:	68 50 24 80 00       	push   $0x802450
  8004a5:	6a 34                	push   $0x34
  8004a7:	68 45 24 80 00       	push   $0x802445
  8004ac:	e8 50 11 00 00       	call   801601 <_panic>
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
  8004c8:	68 50 24 80 00       	push   $0x802450
  8004cd:	6a 38                	push   $0x38
  8004cf:	68 45 24 80 00       	push   $0x802445
  8004d4:	e8 28 11 00 00       	call   801601 <_panic>
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
  8004ec:	e8 b5 1a 00 00       	call   801fa6 <set_pgfault_handler>
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
  800505:	68 69 24 80 00       	push   $0x802469
  80050a:	68 85 00 00 00       	push   $0x85
  80050f:	68 45 24 80 00       	push   $0x802445
  800514:	e8 e8 10 00 00       	call   801601 <_panic>
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
  8005c1:	68 77 24 80 00       	push   $0x802477
  8005c6:	6a 55                	push   $0x55
  8005c8:	68 45 24 80 00       	push   $0x802445
  8005cd:	e8 2f 10 00 00       	call   801601 <_panic>
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
  800606:	68 77 24 80 00       	push   $0x802477
  80060b:	6a 5c                	push   $0x5c
  80060d:	68 45 24 80 00       	push   $0x802445
  800612:	e8 ea 0f 00 00       	call   801601 <_panic>
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
  800634:	68 77 24 80 00       	push   $0x802477
  800639:	6a 60                	push   $0x60
  80063b:	68 45 24 80 00       	push   $0x802445
  800640:	e8 bc 0f 00 00       	call   801601 <_panic>
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
  80065e:	68 77 24 80 00       	push   $0x802477
  800663:	6a 65                	push   $0x65
  800665:	68 45 24 80 00       	push   $0x802445
  80066a:	e8 92 0f 00 00       	call   801601 <_panic>
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
  80071b:	68 bd 24 80 00       	push   $0x8024bd
  800720:	68 d5 00 00 00       	push   $0xd5
  800725:	68 45 24 80 00       	push   $0x802445
  80072a:	e8 d2 0e 00 00       	call   801601 <_panic>
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
  800781:	68 8d 24 80 00       	push   $0x80248d
  800786:	68 ec 00 00 00       	push   $0xec
  80078b:	68 45 24 80 00       	push   $0x802445
  800790:	e8 6c 0e 00 00       	call   801601 <_panic>
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
  8007a1:	53                   	push   %ebx
  8007a2:	83 ec 04             	sub    $0x4,%esp
  8007a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8007a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8007ad:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  8007b0:	85 c0                	test   %eax,%eax
  8007b2:	74 45                	je     8007f9 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  8007b4:	e8 9c f9 ff ff       	call   800155 <sys_getenvid>
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	83 c3 04             	add    $0x4,%ebx
  8007bf:	53                   	push   %ebx
  8007c0:	50                   	push   %eax
  8007c1:	e8 35 ff ff ff       	call   8006fb <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8007c6:	e8 8a f9 ff ff       	call   800155 <sys_getenvid>
  8007cb:	83 c4 08             	add    $0x8,%esp
  8007ce:	6a 04                	push   $0x4
  8007d0:	50                   	push   %eax
  8007d1:	e8 84 fa ff ff       	call   80025a <sys_env_set_status>

		if (r < 0) {
  8007d6:	83 c4 10             	add    $0x10,%esp
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	79 15                	jns    8007f2 <mutex_lock+0x54>
			panic("%e\n", r);
  8007dd:	50                   	push   %eax
  8007de:	68 bd 24 80 00       	push   $0x8024bd
  8007e3:	68 02 01 00 00       	push   $0x102
  8007e8:	68 45 24 80 00       	push   $0x802445
  8007ed:	e8 0f 0e 00 00       	call   801601 <_panic>
		}
		sys_yield();
  8007f2:	e8 7d f9 ff ff       	call   800174 <sys_yield>
  8007f7:	eb 08                	jmp    800801 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8007f9:	e8 57 f9 ff ff       	call   800155 <sys_getenvid>
  8007fe:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  800801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	53                   	push   %ebx
  80080a:	83 ec 04             	sub    $0x4,%esp
  80080d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  800810:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  800814:	74 36                	je     80084c <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  800816:	83 ec 0c             	sub    $0xc,%esp
  800819:	8d 43 04             	lea    0x4(%ebx),%eax
  80081c:	50                   	push   %eax
  80081d:	e8 4d ff ff ff       	call   80076f <queue_pop>
  800822:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  800825:	83 c4 08             	add    $0x8,%esp
  800828:	6a 02                	push   $0x2
  80082a:	50                   	push   %eax
  80082b:	e8 2a fa ff ff       	call   80025a <sys_env_set_status>
		if (r < 0) {
  800830:	83 c4 10             	add    $0x10,%esp
  800833:	85 c0                	test   %eax,%eax
  800835:	79 1d                	jns    800854 <mutex_unlock+0x4e>
			panic("%e\n", r);
  800837:	50                   	push   %eax
  800838:	68 bd 24 80 00       	push   $0x8024bd
  80083d:	68 16 01 00 00       	push   $0x116
  800842:	68 45 24 80 00       	push   $0x802445
  800847:	e8 b5 0d 00 00       	call   801601 <_panic>
  80084c:	b8 00 00 00 00       	mov    $0x0,%eax
  800851:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  800854:	e8 1b f9 ff ff       	call   800174 <sys_yield>
}
  800859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085c:	c9                   	leave  
  80085d:	c3                   	ret    

0080085e <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	53                   	push   %ebx
  800862:	83 ec 04             	sub    $0x4,%esp
  800865:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  800868:	e8 e8 f8 ff ff       	call   800155 <sys_getenvid>
  80086d:	83 ec 04             	sub    $0x4,%esp
  800870:	6a 07                	push   $0x7
  800872:	53                   	push   %ebx
  800873:	50                   	push   %eax
  800874:	e8 1a f9 ff ff       	call   800193 <sys_page_alloc>
  800879:	83 c4 10             	add    $0x10,%esp
  80087c:	85 c0                	test   %eax,%eax
  80087e:	79 15                	jns    800895 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  800880:	50                   	push   %eax
  800881:	68 a8 24 80 00       	push   $0x8024a8
  800886:	68 23 01 00 00       	push   $0x123
  80088b:	68 45 24 80 00       	push   $0x802445
  800890:	e8 6c 0d 00 00       	call   801601 <_panic>
	}	
	mtx->locked = 0;
  800895:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  80089b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  8008a2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  8008a9:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  8008b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b3:	c9                   	leave  
  8008b4:	c3                   	ret    

008008b5 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	56                   	push   %esi
  8008b9:	53                   	push   %ebx
  8008ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8008bd:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8008c0:	eb 20                	jmp    8008e2 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8008c2:	83 ec 0c             	sub    $0xc,%esp
  8008c5:	56                   	push   %esi
  8008c6:	e8 a4 fe ff ff       	call   80076f <queue_pop>
  8008cb:	83 c4 08             	add    $0x8,%esp
  8008ce:	6a 02                	push   $0x2
  8008d0:	50                   	push   %eax
  8008d1:	e8 84 f9 ff ff       	call   80025a <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8008d6:	8b 43 04             	mov    0x4(%ebx),%eax
  8008d9:	8b 40 04             	mov    0x4(%eax),%eax
  8008dc:	89 43 04             	mov    %eax,0x4(%ebx)
  8008df:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8008e2:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8008e6:	75 da                	jne    8008c2 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008e8:	83 ec 04             	sub    $0x4,%esp
  8008eb:	68 00 10 00 00       	push   $0x1000
  8008f0:	6a 00                	push   $0x0
  8008f2:	53                   	push   %ebx
  8008f3:	e8 ac 14 00 00       	call   801da4 <memset>
	mtx = NULL;
}
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	05 00 00 00 30       	add    $0x30000000,%eax
  80090d:	c1 e8 0c             	shr    $0xc,%eax
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	05 00 00 00 30       	add    $0x30000000,%eax
  80091d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800922:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800934:	89 c2                	mov    %eax,%edx
  800936:	c1 ea 16             	shr    $0x16,%edx
  800939:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800940:	f6 c2 01             	test   $0x1,%dl
  800943:	74 11                	je     800956 <fd_alloc+0x2d>
  800945:	89 c2                	mov    %eax,%edx
  800947:	c1 ea 0c             	shr    $0xc,%edx
  80094a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800951:	f6 c2 01             	test   $0x1,%dl
  800954:	75 09                	jne    80095f <fd_alloc+0x36>
			*fd_store = fd;
  800956:	89 01                	mov    %eax,(%ecx)
			return 0;
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
  80095d:	eb 17                	jmp    800976 <fd_alloc+0x4d>
  80095f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800964:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800969:	75 c9                	jne    800934 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80096b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800971:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80097e:	83 f8 1f             	cmp    $0x1f,%eax
  800981:	77 36                	ja     8009b9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800983:	c1 e0 0c             	shl    $0xc,%eax
  800986:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80098b:	89 c2                	mov    %eax,%edx
  80098d:	c1 ea 16             	shr    $0x16,%edx
  800990:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800997:	f6 c2 01             	test   $0x1,%dl
  80099a:	74 24                	je     8009c0 <fd_lookup+0x48>
  80099c:	89 c2                	mov    %eax,%edx
  80099e:	c1 ea 0c             	shr    $0xc,%edx
  8009a1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8009a8:	f6 c2 01             	test   $0x1,%dl
  8009ab:	74 1a                	je     8009c7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8009ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b0:	89 02                	mov    %eax,(%edx)
	return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b7:	eb 13                	jmp    8009cc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8009b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009be:	eb 0c                	jmp    8009cc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8009c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c5:	eb 05                	jmp    8009cc <fd_lookup+0x54>
  8009c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	83 ec 08             	sub    $0x8,%esp
  8009d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d7:	ba 40 25 80 00       	mov    $0x802540,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8009dc:	eb 13                	jmp    8009f1 <dev_lookup+0x23>
  8009de:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009e1:	39 08                	cmp    %ecx,(%eax)
  8009e3:	75 0c                	jne    8009f1 <dev_lookup+0x23>
			*dev = devtab[i];
  8009e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ef:	eb 31                	jmp    800a22 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009f1:	8b 02                	mov    (%edx),%eax
  8009f3:	85 c0                	test   %eax,%eax
  8009f5:	75 e7                	jne    8009de <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8009fc:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800a02:	83 ec 04             	sub    $0x4,%esp
  800a05:	51                   	push   %ecx
  800a06:	50                   	push   %eax
  800a07:	68 c4 24 80 00       	push   $0x8024c4
  800a0c:	e8 c9 0c 00 00       	call   8016da <cprintf>
	*dev = 0;
  800a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800a1a:	83 c4 10             	add    $0x10,%esp
  800a1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	83 ec 10             	sub    $0x10,%esp
  800a2c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a35:	50                   	push   %eax
  800a36:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a3c:	c1 e8 0c             	shr    $0xc,%eax
  800a3f:	50                   	push   %eax
  800a40:	e8 33 ff ff ff       	call   800978 <fd_lookup>
  800a45:	83 c4 08             	add    $0x8,%esp
  800a48:	85 c0                	test   %eax,%eax
  800a4a:	78 05                	js     800a51 <fd_close+0x2d>
	    || fd != fd2)
  800a4c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a4f:	74 0c                	je     800a5d <fd_close+0x39>
		return (must_exist ? r : 0);
  800a51:	84 db                	test   %bl,%bl
  800a53:	ba 00 00 00 00       	mov    $0x0,%edx
  800a58:	0f 44 c2             	cmove  %edx,%eax
  800a5b:	eb 41                	jmp    800a9e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a5d:	83 ec 08             	sub    $0x8,%esp
  800a60:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a63:	50                   	push   %eax
  800a64:	ff 36                	pushl  (%esi)
  800a66:	e8 63 ff ff ff       	call   8009ce <dev_lookup>
  800a6b:	89 c3                	mov    %eax,%ebx
  800a6d:	83 c4 10             	add    $0x10,%esp
  800a70:	85 c0                	test   %eax,%eax
  800a72:	78 1a                	js     800a8e <fd_close+0x6a>
		if (dev->dev_close)
  800a74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a77:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a7a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a7f:	85 c0                	test   %eax,%eax
  800a81:	74 0b                	je     800a8e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a83:	83 ec 0c             	sub    $0xc,%esp
  800a86:	56                   	push   %esi
  800a87:	ff d0                	call   *%eax
  800a89:	89 c3                	mov    %eax,%ebx
  800a8b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a8e:	83 ec 08             	sub    $0x8,%esp
  800a91:	56                   	push   %esi
  800a92:	6a 00                	push   $0x0
  800a94:	e8 7f f7 ff ff       	call   800218 <sys_page_unmap>
	return r;
  800a99:	83 c4 10             	add    $0x10,%esp
  800a9c:	89 d8                	mov    %ebx,%eax
}
  800a9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800aab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aae:	50                   	push   %eax
  800aaf:	ff 75 08             	pushl  0x8(%ebp)
  800ab2:	e8 c1 fe ff ff       	call   800978 <fd_lookup>
  800ab7:	83 c4 08             	add    $0x8,%esp
  800aba:	85 c0                	test   %eax,%eax
  800abc:	78 10                	js     800ace <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800abe:	83 ec 08             	sub    $0x8,%esp
  800ac1:	6a 01                	push   $0x1
  800ac3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ac6:	e8 59 ff ff ff       	call   800a24 <fd_close>
  800acb:	83 c4 10             	add    $0x10,%esp
}
  800ace:	c9                   	leave  
  800acf:	c3                   	ret    

00800ad0 <close_all>:

void
close_all(void)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	53                   	push   %ebx
  800ad4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ad7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	53                   	push   %ebx
  800ae0:	e8 c0 ff ff ff       	call   800aa5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ae5:	83 c3 01             	add    $0x1,%ebx
  800ae8:	83 c4 10             	add    $0x10,%esp
  800aeb:	83 fb 20             	cmp    $0x20,%ebx
  800aee:	75 ec                	jne    800adc <close_all+0xc>
		close(i);
}
  800af0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af3:	c9                   	leave  
  800af4:	c3                   	ret    

00800af5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
  800afb:	83 ec 2c             	sub    $0x2c,%esp
  800afe:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800b01:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800b04:	50                   	push   %eax
  800b05:	ff 75 08             	pushl  0x8(%ebp)
  800b08:	e8 6b fe ff ff       	call   800978 <fd_lookup>
  800b0d:	83 c4 08             	add    $0x8,%esp
  800b10:	85 c0                	test   %eax,%eax
  800b12:	0f 88 c1 00 00 00    	js     800bd9 <dup+0xe4>
		return r;
	close(newfdnum);
  800b18:	83 ec 0c             	sub    $0xc,%esp
  800b1b:	56                   	push   %esi
  800b1c:	e8 84 ff ff ff       	call   800aa5 <close>

	newfd = INDEX2FD(newfdnum);
  800b21:	89 f3                	mov    %esi,%ebx
  800b23:	c1 e3 0c             	shl    $0xc,%ebx
  800b26:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b2c:	83 c4 04             	add    $0x4,%esp
  800b2f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b32:	e8 db fd ff ff       	call   800912 <fd2data>
  800b37:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b39:	89 1c 24             	mov    %ebx,(%esp)
  800b3c:	e8 d1 fd ff ff       	call   800912 <fd2data>
  800b41:	83 c4 10             	add    $0x10,%esp
  800b44:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b47:	89 f8                	mov    %edi,%eax
  800b49:	c1 e8 16             	shr    $0x16,%eax
  800b4c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b53:	a8 01                	test   $0x1,%al
  800b55:	74 37                	je     800b8e <dup+0x99>
  800b57:	89 f8                	mov    %edi,%eax
  800b59:	c1 e8 0c             	shr    $0xc,%eax
  800b5c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b63:	f6 c2 01             	test   $0x1,%dl
  800b66:	74 26                	je     800b8e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b68:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b6f:	83 ec 0c             	sub    $0xc,%esp
  800b72:	25 07 0e 00 00       	and    $0xe07,%eax
  800b77:	50                   	push   %eax
  800b78:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b7b:	6a 00                	push   $0x0
  800b7d:	57                   	push   %edi
  800b7e:	6a 00                	push   $0x0
  800b80:	e8 51 f6 ff ff       	call   8001d6 <sys_page_map>
  800b85:	89 c7                	mov    %eax,%edi
  800b87:	83 c4 20             	add    $0x20,%esp
  800b8a:	85 c0                	test   %eax,%eax
  800b8c:	78 2e                	js     800bbc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b8e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b91:	89 d0                	mov    %edx,%eax
  800b93:	c1 e8 0c             	shr    $0xc,%eax
  800b96:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b9d:	83 ec 0c             	sub    $0xc,%esp
  800ba0:	25 07 0e 00 00       	and    $0xe07,%eax
  800ba5:	50                   	push   %eax
  800ba6:	53                   	push   %ebx
  800ba7:	6a 00                	push   $0x0
  800ba9:	52                   	push   %edx
  800baa:	6a 00                	push   $0x0
  800bac:	e8 25 f6 ff ff       	call   8001d6 <sys_page_map>
  800bb1:	89 c7                	mov    %eax,%edi
  800bb3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800bb6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800bb8:	85 ff                	test   %edi,%edi
  800bba:	79 1d                	jns    800bd9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800bbc:	83 ec 08             	sub    $0x8,%esp
  800bbf:	53                   	push   %ebx
  800bc0:	6a 00                	push   $0x0
  800bc2:	e8 51 f6 ff ff       	call   800218 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800bc7:	83 c4 08             	add    $0x8,%esp
  800bca:	ff 75 d4             	pushl  -0x2c(%ebp)
  800bcd:	6a 00                	push   $0x0
  800bcf:	e8 44 f6 ff ff       	call   800218 <sys_page_unmap>
	return r;
  800bd4:	83 c4 10             	add    $0x10,%esp
  800bd7:	89 f8                	mov    %edi,%eax
}
  800bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	53                   	push   %ebx
  800be5:	83 ec 14             	sub    $0x14,%esp
  800be8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800beb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bee:	50                   	push   %eax
  800bef:	53                   	push   %ebx
  800bf0:	e8 83 fd ff ff       	call   800978 <fd_lookup>
  800bf5:	83 c4 08             	add    $0x8,%esp
  800bf8:	89 c2                	mov    %eax,%edx
  800bfa:	85 c0                	test   %eax,%eax
  800bfc:	78 70                	js     800c6e <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bfe:	83 ec 08             	sub    $0x8,%esp
  800c01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c04:	50                   	push   %eax
  800c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c08:	ff 30                	pushl  (%eax)
  800c0a:	e8 bf fd ff ff       	call   8009ce <dev_lookup>
  800c0f:	83 c4 10             	add    $0x10,%esp
  800c12:	85 c0                	test   %eax,%eax
  800c14:	78 4f                	js     800c65 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800c16:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c19:	8b 42 08             	mov    0x8(%edx),%eax
  800c1c:	83 e0 03             	and    $0x3,%eax
  800c1f:	83 f8 01             	cmp    $0x1,%eax
  800c22:	75 24                	jne    800c48 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800c24:	a1 04 40 80 00       	mov    0x804004,%eax
  800c29:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800c2f:	83 ec 04             	sub    $0x4,%esp
  800c32:	53                   	push   %ebx
  800c33:	50                   	push   %eax
  800c34:	68 05 25 80 00       	push   $0x802505
  800c39:	e8 9c 0a 00 00       	call   8016da <cprintf>
		return -E_INVAL;
  800c3e:	83 c4 10             	add    $0x10,%esp
  800c41:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c46:	eb 26                	jmp    800c6e <read+0x8d>
	}
	if (!dev->dev_read)
  800c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c4b:	8b 40 08             	mov    0x8(%eax),%eax
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	74 17                	je     800c69 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c52:	83 ec 04             	sub    $0x4,%esp
  800c55:	ff 75 10             	pushl  0x10(%ebp)
  800c58:	ff 75 0c             	pushl  0xc(%ebp)
  800c5b:	52                   	push   %edx
  800c5c:	ff d0                	call   *%eax
  800c5e:	89 c2                	mov    %eax,%edx
  800c60:	83 c4 10             	add    $0x10,%esp
  800c63:	eb 09                	jmp    800c6e <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c65:	89 c2                	mov    %eax,%edx
  800c67:	eb 05                	jmp    800c6e <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c69:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c6e:	89 d0                	mov    %edx,%eax
  800c70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c73:	c9                   	leave  
  800c74:	c3                   	ret    

00800c75 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
  800c7e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c81:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c89:	eb 21                	jmp    800cac <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c8b:	83 ec 04             	sub    $0x4,%esp
  800c8e:	89 f0                	mov    %esi,%eax
  800c90:	29 d8                	sub    %ebx,%eax
  800c92:	50                   	push   %eax
  800c93:	89 d8                	mov    %ebx,%eax
  800c95:	03 45 0c             	add    0xc(%ebp),%eax
  800c98:	50                   	push   %eax
  800c99:	57                   	push   %edi
  800c9a:	e8 42 ff ff ff       	call   800be1 <read>
		if (m < 0)
  800c9f:	83 c4 10             	add    $0x10,%esp
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	78 10                	js     800cb6 <readn+0x41>
			return m;
		if (m == 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	74 0a                	je     800cb4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800caa:	01 c3                	add    %eax,%ebx
  800cac:	39 f3                	cmp    %esi,%ebx
  800cae:	72 db                	jb     800c8b <readn+0x16>
  800cb0:	89 d8                	mov    %ebx,%eax
  800cb2:	eb 02                	jmp    800cb6 <readn+0x41>
  800cb4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 14             	sub    $0x14,%esp
  800cc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cc8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ccb:	50                   	push   %eax
  800ccc:	53                   	push   %ebx
  800ccd:	e8 a6 fc ff ff       	call   800978 <fd_lookup>
  800cd2:	83 c4 08             	add    $0x8,%esp
  800cd5:	89 c2                	mov    %eax,%edx
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	78 6b                	js     800d46 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cdb:	83 ec 08             	sub    $0x8,%esp
  800cde:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ce1:	50                   	push   %eax
  800ce2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ce5:	ff 30                	pushl  (%eax)
  800ce7:	e8 e2 fc ff ff       	call   8009ce <dev_lookup>
  800cec:	83 c4 10             	add    $0x10,%esp
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	78 4a                	js     800d3d <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cf6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cfa:	75 24                	jne    800d20 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800cfc:	a1 04 40 80 00       	mov    0x804004,%eax
  800d01:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800d07:	83 ec 04             	sub    $0x4,%esp
  800d0a:	53                   	push   %ebx
  800d0b:	50                   	push   %eax
  800d0c:	68 21 25 80 00       	push   $0x802521
  800d11:	e8 c4 09 00 00       	call   8016da <cprintf>
		return -E_INVAL;
  800d16:	83 c4 10             	add    $0x10,%esp
  800d19:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d1e:	eb 26                	jmp    800d46 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800d20:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d23:	8b 52 0c             	mov    0xc(%edx),%edx
  800d26:	85 d2                	test   %edx,%edx
  800d28:	74 17                	je     800d41 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d2a:	83 ec 04             	sub    $0x4,%esp
  800d2d:	ff 75 10             	pushl  0x10(%ebp)
  800d30:	ff 75 0c             	pushl  0xc(%ebp)
  800d33:	50                   	push   %eax
  800d34:	ff d2                	call   *%edx
  800d36:	89 c2                	mov    %eax,%edx
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	eb 09                	jmp    800d46 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d3d:	89 c2                	mov    %eax,%edx
  800d3f:	eb 05                	jmp    800d46 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d41:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d46:	89 d0                	mov    %edx,%eax
  800d48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    

00800d4d <seek>:

int
seek(int fdnum, off_t offset)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d53:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d56:	50                   	push   %eax
  800d57:	ff 75 08             	pushl  0x8(%ebp)
  800d5a:	e8 19 fc ff ff       	call   800978 <fd_lookup>
  800d5f:	83 c4 08             	add    $0x8,%esp
  800d62:	85 c0                	test   %eax,%eax
  800d64:	78 0e                	js     800d74 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d66:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d6c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d74:	c9                   	leave  
  800d75:	c3                   	ret    

00800d76 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	53                   	push   %ebx
  800d7a:	83 ec 14             	sub    $0x14,%esp
  800d7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d80:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d83:	50                   	push   %eax
  800d84:	53                   	push   %ebx
  800d85:	e8 ee fb ff ff       	call   800978 <fd_lookup>
  800d8a:	83 c4 08             	add    $0x8,%esp
  800d8d:	89 c2                	mov    %eax,%edx
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	78 68                	js     800dfb <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d93:	83 ec 08             	sub    $0x8,%esp
  800d96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d99:	50                   	push   %eax
  800d9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d9d:	ff 30                	pushl  (%eax)
  800d9f:	e8 2a fc ff ff       	call   8009ce <dev_lookup>
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	78 47                	js     800df2 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800dab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dae:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800db2:	75 24                	jne    800dd8 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800db4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800db9:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800dbf:	83 ec 04             	sub    $0x4,%esp
  800dc2:	53                   	push   %ebx
  800dc3:	50                   	push   %eax
  800dc4:	68 e4 24 80 00       	push   $0x8024e4
  800dc9:	e8 0c 09 00 00       	call   8016da <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800dce:	83 c4 10             	add    $0x10,%esp
  800dd1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800dd6:	eb 23                	jmp    800dfb <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800dd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ddb:	8b 52 18             	mov    0x18(%edx),%edx
  800dde:	85 d2                	test   %edx,%edx
  800de0:	74 14                	je     800df6 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800de2:	83 ec 08             	sub    $0x8,%esp
  800de5:	ff 75 0c             	pushl  0xc(%ebp)
  800de8:	50                   	push   %eax
  800de9:	ff d2                	call   *%edx
  800deb:	89 c2                	mov    %eax,%edx
  800ded:	83 c4 10             	add    $0x10,%esp
  800df0:	eb 09                	jmp    800dfb <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800df2:	89 c2                	mov    %eax,%edx
  800df4:	eb 05                	jmp    800dfb <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800df6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800dfb:	89 d0                	mov    %edx,%eax
  800dfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e00:	c9                   	leave  
  800e01:	c3                   	ret    

00800e02 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	53                   	push   %ebx
  800e06:	83 ec 14             	sub    $0x14,%esp
  800e09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e0f:	50                   	push   %eax
  800e10:	ff 75 08             	pushl  0x8(%ebp)
  800e13:	e8 60 fb ff ff       	call   800978 <fd_lookup>
  800e18:	83 c4 08             	add    $0x8,%esp
  800e1b:	89 c2                	mov    %eax,%edx
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	78 58                	js     800e79 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e21:	83 ec 08             	sub    $0x8,%esp
  800e24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e27:	50                   	push   %eax
  800e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2b:	ff 30                	pushl  (%eax)
  800e2d:	e8 9c fb ff ff       	call   8009ce <dev_lookup>
  800e32:	83 c4 10             	add    $0x10,%esp
  800e35:	85 c0                	test   %eax,%eax
  800e37:	78 37                	js     800e70 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e40:	74 32                	je     800e74 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e42:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e45:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e4c:	00 00 00 
	stat->st_isdir = 0;
  800e4f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e56:	00 00 00 
	stat->st_dev = dev;
  800e59:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e5f:	83 ec 08             	sub    $0x8,%esp
  800e62:	53                   	push   %ebx
  800e63:	ff 75 f0             	pushl  -0x10(%ebp)
  800e66:	ff 50 14             	call   *0x14(%eax)
  800e69:	89 c2                	mov    %eax,%edx
  800e6b:	83 c4 10             	add    $0x10,%esp
  800e6e:	eb 09                	jmp    800e79 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e70:	89 c2                	mov    %eax,%edx
  800e72:	eb 05                	jmp    800e79 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e74:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e79:	89 d0                	mov    %edx,%eax
  800e7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	56                   	push   %esi
  800e84:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e85:	83 ec 08             	sub    $0x8,%esp
  800e88:	6a 00                	push   $0x0
  800e8a:	ff 75 08             	pushl  0x8(%ebp)
  800e8d:	e8 e3 01 00 00       	call   801075 <open>
  800e92:	89 c3                	mov    %eax,%ebx
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	85 c0                	test   %eax,%eax
  800e99:	78 1b                	js     800eb6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e9b:	83 ec 08             	sub    $0x8,%esp
  800e9e:	ff 75 0c             	pushl  0xc(%ebp)
  800ea1:	50                   	push   %eax
  800ea2:	e8 5b ff ff ff       	call   800e02 <fstat>
  800ea7:	89 c6                	mov    %eax,%esi
	close(fd);
  800ea9:	89 1c 24             	mov    %ebx,(%esp)
  800eac:	e8 f4 fb ff ff       	call   800aa5 <close>
	return r;
  800eb1:	83 c4 10             	add    $0x10,%esp
  800eb4:	89 f0                	mov    %esi,%eax
}
  800eb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	56                   	push   %esi
  800ec1:	53                   	push   %ebx
  800ec2:	89 c6                	mov    %eax,%esi
  800ec4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800ec6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800ecd:	75 12                	jne    800ee1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ecf:	83 ec 0c             	sub    $0xc,%esp
  800ed2:	6a 01                	push   $0x1
  800ed4:	e8 15 12 00 00       	call   8020ee <ipc_find_env>
  800ed9:	a3 00 40 80 00       	mov    %eax,0x804000
  800ede:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ee1:	6a 07                	push   $0x7
  800ee3:	68 00 50 80 00       	push   $0x805000
  800ee8:	56                   	push   %esi
  800ee9:	ff 35 00 40 80 00    	pushl  0x804000
  800eef:	e8 98 11 00 00       	call   80208c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ef4:	83 c4 0c             	add    $0xc,%esp
  800ef7:	6a 00                	push   $0x0
  800ef9:	53                   	push   %ebx
  800efa:	6a 00                	push   $0x0
  800efc:	e8 10 11 00 00       	call   802011 <ipc_recv>
}
  800f01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f11:	8b 40 0c             	mov    0xc(%eax),%eax
  800f14:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800f19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800f21:	ba 00 00 00 00       	mov    $0x0,%edx
  800f26:	b8 02 00 00 00       	mov    $0x2,%eax
  800f2b:	e8 8d ff ff ff       	call   800ebd <fsipc>
}
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    

00800f32 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f38:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3b:	8b 40 0c             	mov    0xc(%eax),%eax
  800f3e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f43:	ba 00 00 00 00       	mov    $0x0,%edx
  800f48:	b8 06 00 00 00       	mov    $0x6,%eax
  800f4d:	e8 6b ff ff ff       	call   800ebd <fsipc>
}
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	53                   	push   %ebx
  800f58:	83 ec 04             	sub    $0x4,%esp
  800f5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f61:	8b 40 0c             	mov    0xc(%eax),%eax
  800f64:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f69:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6e:	b8 05 00 00 00       	mov    $0x5,%eax
  800f73:	e8 45 ff ff ff       	call   800ebd <fsipc>
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	78 2c                	js     800fa8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f7c:	83 ec 08             	sub    $0x8,%esp
  800f7f:	68 00 50 80 00       	push   $0x805000
  800f84:	53                   	push   %ebx
  800f85:	e8 d5 0c 00 00       	call   801c5f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f8a:	a1 80 50 80 00       	mov    0x805080,%eax
  800f8f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f95:	a1 84 50 80 00       	mov    0x805084,%eax
  800f9a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fa8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fab:	c9                   	leave  
  800fac:	c3                   	ret    

00800fad <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 0c             	sub    $0xc,%esp
  800fb3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800fb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb9:	8b 52 0c             	mov    0xc(%edx),%edx
  800fbc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800fc2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800fc7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800fcc:	0f 47 c2             	cmova  %edx,%eax
  800fcf:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800fd4:	50                   	push   %eax
  800fd5:	ff 75 0c             	pushl  0xc(%ebp)
  800fd8:	68 08 50 80 00       	push   $0x805008
  800fdd:	e8 0f 0e 00 00       	call   801df1 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fe2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe7:	b8 04 00 00 00       	mov    $0x4,%eax
  800fec:	e8 cc fe ff ff       	call   800ebd <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
  800ff8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ffb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffe:	8b 40 0c             	mov    0xc(%eax),%eax
  801001:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801006:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80100c:	ba 00 00 00 00       	mov    $0x0,%edx
  801011:	b8 03 00 00 00       	mov    $0x3,%eax
  801016:	e8 a2 fe ff ff       	call   800ebd <fsipc>
  80101b:	89 c3                	mov    %eax,%ebx
  80101d:	85 c0                	test   %eax,%eax
  80101f:	78 4b                	js     80106c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801021:	39 c6                	cmp    %eax,%esi
  801023:	73 16                	jae    80103b <devfile_read+0x48>
  801025:	68 50 25 80 00       	push   $0x802550
  80102a:	68 57 25 80 00       	push   $0x802557
  80102f:	6a 7c                	push   $0x7c
  801031:	68 6c 25 80 00       	push   $0x80256c
  801036:	e8 c6 05 00 00       	call   801601 <_panic>
	assert(r <= PGSIZE);
  80103b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801040:	7e 16                	jle    801058 <devfile_read+0x65>
  801042:	68 77 25 80 00       	push   $0x802577
  801047:	68 57 25 80 00       	push   $0x802557
  80104c:	6a 7d                	push   $0x7d
  80104e:	68 6c 25 80 00       	push   $0x80256c
  801053:	e8 a9 05 00 00       	call   801601 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801058:	83 ec 04             	sub    $0x4,%esp
  80105b:	50                   	push   %eax
  80105c:	68 00 50 80 00       	push   $0x805000
  801061:	ff 75 0c             	pushl  0xc(%ebp)
  801064:	e8 88 0d 00 00       	call   801df1 <memmove>
	return r;
  801069:	83 c4 10             	add    $0x10,%esp
}
  80106c:	89 d8                	mov    %ebx,%eax
  80106e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	53                   	push   %ebx
  801079:	83 ec 20             	sub    $0x20,%esp
  80107c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80107f:	53                   	push   %ebx
  801080:	e8 a1 0b 00 00       	call   801c26 <strlen>
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80108d:	7f 67                	jg     8010f6 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801095:	50                   	push   %eax
  801096:	e8 8e f8 ff ff       	call   800929 <fd_alloc>
  80109b:	83 c4 10             	add    $0x10,%esp
		return r;
  80109e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 57                	js     8010fb <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	53                   	push   %ebx
  8010a8:	68 00 50 80 00       	push   $0x805000
  8010ad:	e8 ad 0b 00 00       	call   801c5f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8010b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8010ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c2:	e8 f6 fd ff ff       	call   800ebd <fsipc>
  8010c7:	89 c3                	mov    %eax,%ebx
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	79 14                	jns    8010e4 <open+0x6f>
		fd_close(fd, 0);
  8010d0:	83 ec 08             	sub    $0x8,%esp
  8010d3:	6a 00                	push   $0x0
  8010d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8010d8:	e8 47 f9 ff ff       	call   800a24 <fd_close>
		return r;
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	89 da                	mov    %ebx,%edx
  8010e2:	eb 17                	jmp    8010fb <open+0x86>
	}

	return fd2num(fd);
  8010e4:	83 ec 0c             	sub    $0xc,%esp
  8010e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ea:	e8 13 f8 ff ff       	call   800902 <fd2num>
  8010ef:	89 c2                	mov    %eax,%edx
  8010f1:	83 c4 10             	add    $0x10,%esp
  8010f4:	eb 05                	jmp    8010fb <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010f6:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010fb:	89 d0                	mov    %edx,%eax
  8010fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801100:	c9                   	leave  
  801101:	c3                   	ret    

00801102 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801108:	ba 00 00 00 00       	mov    $0x0,%edx
  80110d:	b8 08 00 00 00       	mov    $0x8,%eax
  801112:	e8 a6 fd ff ff       	call   800ebd <fsipc>
}
  801117:	c9                   	leave  
  801118:	c3                   	ret    

00801119 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	56                   	push   %esi
  80111d:	53                   	push   %ebx
  80111e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	ff 75 08             	pushl  0x8(%ebp)
  801127:	e8 e6 f7 ff ff       	call   800912 <fd2data>
  80112c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80112e:	83 c4 08             	add    $0x8,%esp
  801131:	68 83 25 80 00       	push   $0x802583
  801136:	53                   	push   %ebx
  801137:	e8 23 0b 00 00       	call   801c5f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80113c:	8b 46 04             	mov    0x4(%esi),%eax
  80113f:	2b 06                	sub    (%esi),%eax
  801141:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801147:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80114e:	00 00 00 
	stat->st_dev = &devpipe;
  801151:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801158:	30 80 00 
	return 0;
}
  80115b:	b8 00 00 00 00       	mov    $0x0,%eax
  801160:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801163:	5b                   	pop    %ebx
  801164:	5e                   	pop    %esi
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	53                   	push   %ebx
  80116b:	83 ec 0c             	sub    $0xc,%esp
  80116e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801171:	53                   	push   %ebx
  801172:	6a 00                	push   $0x0
  801174:	e8 9f f0 ff ff       	call   800218 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801179:	89 1c 24             	mov    %ebx,(%esp)
  80117c:	e8 91 f7 ff ff       	call   800912 <fd2data>
  801181:	83 c4 08             	add    $0x8,%esp
  801184:	50                   	push   %eax
  801185:	6a 00                	push   $0x0
  801187:	e8 8c f0 ff ff       	call   800218 <sys_page_unmap>
}
  80118c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118f:	c9                   	leave  
  801190:	c3                   	ret    

00801191 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	57                   	push   %edi
  801195:	56                   	push   %esi
  801196:	53                   	push   %ebx
  801197:	83 ec 1c             	sub    $0x1c,%esp
  80119a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80119d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80119f:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a4:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8011aa:	83 ec 0c             	sub    $0xc,%esp
  8011ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b0:	e8 7e 0f 00 00       	call   802133 <pageref>
  8011b5:	89 c3                	mov    %eax,%ebx
  8011b7:	89 3c 24             	mov    %edi,(%esp)
  8011ba:	e8 74 0f 00 00       	call   802133 <pageref>
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	39 c3                	cmp    %eax,%ebx
  8011c4:	0f 94 c1             	sete   %cl
  8011c7:	0f b6 c9             	movzbl %cl,%ecx
  8011ca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8011cd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8011d3:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  8011d9:	39 ce                	cmp    %ecx,%esi
  8011db:	74 1e                	je     8011fb <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8011dd:	39 c3                	cmp    %eax,%ebx
  8011df:	75 be                	jne    80119f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011e1:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ea:	50                   	push   %eax
  8011eb:	56                   	push   %esi
  8011ec:	68 8a 25 80 00       	push   $0x80258a
  8011f1:	e8 e4 04 00 00       	call   8016da <cprintf>
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	eb a4                	jmp    80119f <_pipeisclosed+0xe>
	}
}
  8011fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801201:	5b                   	pop    %ebx
  801202:	5e                   	pop    %esi
  801203:	5f                   	pop    %edi
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	57                   	push   %edi
  80120a:	56                   	push   %esi
  80120b:	53                   	push   %ebx
  80120c:	83 ec 28             	sub    $0x28,%esp
  80120f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801212:	56                   	push   %esi
  801213:	e8 fa f6 ff ff       	call   800912 <fd2data>
  801218:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	bf 00 00 00 00       	mov    $0x0,%edi
  801222:	eb 4b                	jmp    80126f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801224:	89 da                	mov    %ebx,%edx
  801226:	89 f0                	mov    %esi,%eax
  801228:	e8 64 ff ff ff       	call   801191 <_pipeisclosed>
  80122d:	85 c0                	test   %eax,%eax
  80122f:	75 48                	jne    801279 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801231:	e8 3e ef ff ff       	call   800174 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801236:	8b 43 04             	mov    0x4(%ebx),%eax
  801239:	8b 0b                	mov    (%ebx),%ecx
  80123b:	8d 51 20             	lea    0x20(%ecx),%edx
  80123e:	39 d0                	cmp    %edx,%eax
  801240:	73 e2                	jae    801224 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801245:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801249:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80124c:	89 c2                	mov    %eax,%edx
  80124e:	c1 fa 1f             	sar    $0x1f,%edx
  801251:	89 d1                	mov    %edx,%ecx
  801253:	c1 e9 1b             	shr    $0x1b,%ecx
  801256:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801259:	83 e2 1f             	and    $0x1f,%edx
  80125c:	29 ca                	sub    %ecx,%edx
  80125e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801262:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801266:	83 c0 01             	add    $0x1,%eax
  801269:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80126c:	83 c7 01             	add    $0x1,%edi
  80126f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801272:	75 c2                	jne    801236 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801274:	8b 45 10             	mov    0x10(%ebp),%eax
  801277:	eb 05                	jmp    80127e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801279:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80127e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801281:	5b                   	pop    %ebx
  801282:	5e                   	pop    %esi
  801283:	5f                   	pop    %edi
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    

00801286 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	57                   	push   %edi
  80128a:	56                   	push   %esi
  80128b:	53                   	push   %ebx
  80128c:	83 ec 18             	sub    $0x18,%esp
  80128f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801292:	57                   	push   %edi
  801293:	e8 7a f6 ff ff       	call   800912 <fd2data>
  801298:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012a2:	eb 3d                	jmp    8012e1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8012a4:	85 db                	test   %ebx,%ebx
  8012a6:	74 04                	je     8012ac <devpipe_read+0x26>
				return i;
  8012a8:	89 d8                	mov    %ebx,%eax
  8012aa:	eb 44                	jmp    8012f0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8012ac:	89 f2                	mov    %esi,%edx
  8012ae:	89 f8                	mov    %edi,%eax
  8012b0:	e8 dc fe ff ff       	call   801191 <_pipeisclosed>
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	75 32                	jne    8012eb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8012b9:	e8 b6 ee ff ff       	call   800174 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8012be:	8b 06                	mov    (%esi),%eax
  8012c0:	3b 46 04             	cmp    0x4(%esi),%eax
  8012c3:	74 df                	je     8012a4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8012c5:	99                   	cltd   
  8012c6:	c1 ea 1b             	shr    $0x1b,%edx
  8012c9:	01 d0                	add    %edx,%eax
  8012cb:	83 e0 1f             	and    $0x1f,%eax
  8012ce:	29 d0                	sub    %edx,%eax
  8012d0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8012d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8012db:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012de:	83 c3 01             	add    $0x1,%ebx
  8012e1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012e4:	75 d8                	jne    8012be <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8012e9:	eb 05                	jmp    8012f0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012eb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5e                   	pop    %esi
  8012f5:	5f                   	pop    %edi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	56                   	push   %esi
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801300:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801303:	50                   	push   %eax
  801304:	e8 20 f6 ff ff       	call   800929 <fd_alloc>
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	89 c2                	mov    %eax,%edx
  80130e:	85 c0                	test   %eax,%eax
  801310:	0f 88 2c 01 00 00    	js     801442 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801316:	83 ec 04             	sub    $0x4,%esp
  801319:	68 07 04 00 00       	push   $0x407
  80131e:	ff 75 f4             	pushl  -0xc(%ebp)
  801321:	6a 00                	push   $0x0
  801323:	e8 6b ee ff ff       	call   800193 <sys_page_alloc>
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	89 c2                	mov    %eax,%edx
  80132d:	85 c0                	test   %eax,%eax
  80132f:	0f 88 0d 01 00 00    	js     801442 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801335:	83 ec 0c             	sub    $0xc,%esp
  801338:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	e8 e8 f5 ff ff       	call   800929 <fd_alloc>
  801341:	89 c3                	mov    %eax,%ebx
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	85 c0                	test   %eax,%eax
  801348:	0f 88 e2 00 00 00    	js     801430 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80134e:	83 ec 04             	sub    $0x4,%esp
  801351:	68 07 04 00 00       	push   $0x407
  801356:	ff 75 f0             	pushl  -0x10(%ebp)
  801359:	6a 00                	push   $0x0
  80135b:	e8 33 ee ff ff       	call   800193 <sys_page_alloc>
  801360:	89 c3                	mov    %eax,%ebx
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	85 c0                	test   %eax,%eax
  801367:	0f 88 c3 00 00 00    	js     801430 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80136d:	83 ec 0c             	sub    $0xc,%esp
  801370:	ff 75 f4             	pushl  -0xc(%ebp)
  801373:	e8 9a f5 ff ff       	call   800912 <fd2data>
  801378:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80137a:	83 c4 0c             	add    $0xc,%esp
  80137d:	68 07 04 00 00       	push   $0x407
  801382:	50                   	push   %eax
  801383:	6a 00                	push   $0x0
  801385:	e8 09 ee ff ff       	call   800193 <sys_page_alloc>
  80138a:	89 c3                	mov    %eax,%ebx
  80138c:	83 c4 10             	add    $0x10,%esp
  80138f:	85 c0                	test   %eax,%eax
  801391:	0f 88 89 00 00 00    	js     801420 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801397:	83 ec 0c             	sub    $0xc,%esp
  80139a:	ff 75 f0             	pushl  -0x10(%ebp)
  80139d:	e8 70 f5 ff ff       	call   800912 <fd2data>
  8013a2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8013a9:	50                   	push   %eax
  8013aa:	6a 00                	push   $0x0
  8013ac:	56                   	push   %esi
  8013ad:	6a 00                	push   $0x0
  8013af:	e8 22 ee ff ff       	call   8001d6 <sys_page_map>
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	83 c4 20             	add    $0x20,%esp
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	78 55                	js     801412 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8013bd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8013c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8013d2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013db:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8013dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013e7:	83 ec 0c             	sub    $0xc,%esp
  8013ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ed:	e8 10 f5 ff ff       	call   800902 <fd2num>
  8013f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013f7:	83 c4 04             	add    $0x4,%esp
  8013fa:	ff 75 f0             	pushl  -0x10(%ebp)
  8013fd:	e8 00 f5 ff ff       	call   800902 <fd2num>
  801402:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801405:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	ba 00 00 00 00       	mov    $0x0,%edx
  801410:	eb 30                	jmp    801442 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	56                   	push   %esi
  801416:	6a 00                	push   $0x0
  801418:	e8 fb ed ff ff       	call   800218 <sys_page_unmap>
  80141d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801420:	83 ec 08             	sub    $0x8,%esp
  801423:	ff 75 f0             	pushl  -0x10(%ebp)
  801426:	6a 00                	push   $0x0
  801428:	e8 eb ed ff ff       	call   800218 <sys_page_unmap>
  80142d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801430:	83 ec 08             	sub    $0x8,%esp
  801433:	ff 75 f4             	pushl  -0xc(%ebp)
  801436:	6a 00                	push   $0x0
  801438:	e8 db ed ff ff       	call   800218 <sys_page_unmap>
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801442:	89 d0                	mov    %edx,%eax
  801444:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801447:	5b                   	pop    %ebx
  801448:	5e                   	pop    %esi
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    

0080144b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801451:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801454:	50                   	push   %eax
  801455:	ff 75 08             	pushl  0x8(%ebp)
  801458:	e8 1b f5 ff ff       	call   800978 <fd_lookup>
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	85 c0                	test   %eax,%eax
  801462:	78 18                	js     80147c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801464:	83 ec 0c             	sub    $0xc,%esp
  801467:	ff 75 f4             	pushl  -0xc(%ebp)
  80146a:	e8 a3 f4 ff ff       	call   800912 <fd2data>
	return _pipeisclosed(fd, p);
  80146f:	89 c2                	mov    %eax,%edx
  801471:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801474:	e8 18 fd ff ff       	call   801191 <_pipeisclosed>
  801479:	83 c4 10             	add    $0x10,%esp
}
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801481:	b8 00 00 00 00       	mov    $0x0,%eax
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80148e:	68 a2 25 80 00       	push   $0x8025a2
  801493:	ff 75 0c             	pushl  0xc(%ebp)
  801496:	e8 c4 07 00 00       	call   801c5f <strcpy>
	return 0;
}
  80149b:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    

008014a2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	57                   	push   %edi
  8014a6:	56                   	push   %esi
  8014a7:	53                   	push   %ebx
  8014a8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014ae:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014b3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014b9:	eb 2d                	jmp    8014e8 <devcons_write+0x46>
		m = n - tot;
  8014bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014be:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8014c0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8014c3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8014c8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014cb:	83 ec 04             	sub    $0x4,%esp
  8014ce:	53                   	push   %ebx
  8014cf:	03 45 0c             	add    0xc(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	57                   	push   %edi
  8014d4:	e8 18 09 00 00       	call   801df1 <memmove>
		sys_cputs(buf, m);
  8014d9:	83 c4 08             	add    $0x8,%esp
  8014dc:	53                   	push   %ebx
  8014dd:	57                   	push   %edi
  8014de:	e8 f4 eb ff ff       	call   8000d7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014e3:	01 de                	add    %ebx,%esi
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	89 f0                	mov    %esi,%eax
  8014ea:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014ed:	72 cc                	jb     8014bb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f2:	5b                   	pop    %ebx
  8014f3:	5e                   	pop    %esi
  8014f4:	5f                   	pop    %edi
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    

008014f7 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	83 ec 08             	sub    $0x8,%esp
  8014fd:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801502:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801506:	74 2a                	je     801532 <devcons_read+0x3b>
  801508:	eb 05                	jmp    80150f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80150a:	e8 65 ec ff ff       	call   800174 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80150f:	e8 e1 eb ff ff       	call   8000f5 <sys_cgetc>
  801514:	85 c0                	test   %eax,%eax
  801516:	74 f2                	je     80150a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 16                	js     801532 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80151c:	83 f8 04             	cmp    $0x4,%eax
  80151f:	74 0c                	je     80152d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801521:	8b 55 0c             	mov    0xc(%ebp),%edx
  801524:	88 02                	mov    %al,(%edx)
	return 1;
  801526:	b8 01 00 00 00       	mov    $0x1,%eax
  80152b:	eb 05                	jmp    801532 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80152d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801532:	c9                   	leave  
  801533:	c3                   	ret    

00801534 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80153a:	8b 45 08             	mov    0x8(%ebp),%eax
  80153d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801540:	6a 01                	push   $0x1
  801542:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801545:	50                   	push   %eax
  801546:	e8 8c eb ff ff       	call   8000d7 <sys_cputs>
}
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	c9                   	leave  
  80154f:	c3                   	ret    

00801550 <getchar>:

int
getchar(void)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801556:	6a 01                	push   $0x1
  801558:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80155b:	50                   	push   %eax
  80155c:	6a 00                	push   $0x0
  80155e:	e8 7e f6 ff ff       	call   800be1 <read>
	if (r < 0)
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	85 c0                	test   %eax,%eax
  801568:	78 0f                	js     801579 <getchar+0x29>
		return r;
	if (r < 1)
  80156a:	85 c0                	test   %eax,%eax
  80156c:	7e 06                	jle    801574 <getchar+0x24>
		return -E_EOF;
	return c;
  80156e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801572:	eb 05                	jmp    801579 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801574:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801579:	c9                   	leave  
  80157a:	c3                   	ret    

0080157b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801581:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801584:	50                   	push   %eax
  801585:	ff 75 08             	pushl  0x8(%ebp)
  801588:	e8 eb f3 ff ff       	call   800978 <fd_lookup>
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	85 c0                	test   %eax,%eax
  801592:	78 11                	js     8015a5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801594:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801597:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80159d:	39 10                	cmp    %edx,(%eax)
  80159f:	0f 94 c0             	sete   %al
  8015a2:	0f b6 c0             	movzbl %al,%eax
}
  8015a5:	c9                   	leave  
  8015a6:	c3                   	ret    

008015a7 <opencons>:

int
opencons(void)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8015ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b0:	50                   	push   %eax
  8015b1:	e8 73 f3 ff ff       	call   800929 <fd_alloc>
  8015b6:	83 c4 10             	add    $0x10,%esp
		return r;
  8015b9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 3e                	js     8015fd <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015bf:	83 ec 04             	sub    $0x4,%esp
  8015c2:	68 07 04 00 00       	push   $0x407
  8015c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ca:	6a 00                	push   $0x0
  8015cc:	e8 c2 eb ff ff       	call   800193 <sys_page_alloc>
  8015d1:	83 c4 10             	add    $0x10,%esp
		return r;
  8015d4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 23                	js     8015fd <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8015da:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015ef:	83 ec 0c             	sub    $0xc,%esp
  8015f2:	50                   	push   %eax
  8015f3:	e8 0a f3 ff ff       	call   800902 <fd2num>
  8015f8:	89 c2                	mov    %eax,%edx
  8015fa:	83 c4 10             	add    $0x10,%esp
}
  8015fd:	89 d0                	mov    %edx,%eax
  8015ff:	c9                   	leave  
  801600:	c3                   	ret    

00801601 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	56                   	push   %esi
  801605:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801606:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801609:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80160f:	e8 41 eb ff ff       	call   800155 <sys_getenvid>
  801614:	83 ec 0c             	sub    $0xc,%esp
  801617:	ff 75 0c             	pushl  0xc(%ebp)
  80161a:	ff 75 08             	pushl  0x8(%ebp)
  80161d:	56                   	push   %esi
  80161e:	50                   	push   %eax
  80161f:	68 b0 25 80 00       	push   $0x8025b0
  801624:	e8 b1 00 00 00       	call   8016da <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801629:	83 c4 18             	add    $0x18,%esp
  80162c:	53                   	push   %ebx
  80162d:	ff 75 10             	pushl  0x10(%ebp)
  801630:	e8 54 00 00 00       	call   801689 <vcprintf>
	cprintf("\n");
  801635:	c7 04 24 a6 24 80 00 	movl   $0x8024a6,(%esp)
  80163c:	e8 99 00 00 00       	call   8016da <cprintf>
  801641:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801644:	cc                   	int3   
  801645:	eb fd                	jmp    801644 <_panic+0x43>

00801647 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	53                   	push   %ebx
  80164b:	83 ec 04             	sub    $0x4,%esp
  80164e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801651:	8b 13                	mov    (%ebx),%edx
  801653:	8d 42 01             	lea    0x1(%edx),%eax
  801656:	89 03                	mov    %eax,(%ebx)
  801658:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80165b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80165f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801664:	75 1a                	jne    801680 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	68 ff 00 00 00       	push   $0xff
  80166e:	8d 43 08             	lea    0x8(%ebx),%eax
  801671:	50                   	push   %eax
  801672:	e8 60 ea ff ff       	call   8000d7 <sys_cputs>
		b->idx = 0;
  801677:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80167d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801680:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801684:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801687:	c9                   	leave  
  801688:	c3                   	ret    

00801689 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801692:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801699:	00 00 00 
	b.cnt = 0;
  80169c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8016a3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8016a6:	ff 75 0c             	pushl  0xc(%ebp)
  8016a9:	ff 75 08             	pushl  0x8(%ebp)
  8016ac:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8016b2:	50                   	push   %eax
  8016b3:	68 47 16 80 00       	push   $0x801647
  8016b8:	e8 54 01 00 00       	call   801811 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8016bd:	83 c4 08             	add    $0x8,%esp
  8016c0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8016c6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8016cc:	50                   	push   %eax
  8016cd:	e8 05 ea ff ff       	call   8000d7 <sys_cputs>

	return b.cnt;
}
  8016d2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016e0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016e3:	50                   	push   %eax
  8016e4:	ff 75 08             	pushl  0x8(%ebp)
  8016e7:	e8 9d ff ff ff       	call   801689 <vcprintf>
	va_end(ap);

	return cnt;
}
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	57                   	push   %edi
  8016f2:	56                   	push   %esi
  8016f3:	53                   	push   %ebx
  8016f4:	83 ec 1c             	sub    $0x1c,%esp
  8016f7:	89 c7                	mov    %eax,%edi
  8016f9:	89 d6                	mov    %edx,%esi
  8016fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801701:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801704:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801707:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80170a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80170f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801712:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801715:	39 d3                	cmp    %edx,%ebx
  801717:	72 05                	jb     80171e <printnum+0x30>
  801719:	39 45 10             	cmp    %eax,0x10(%ebp)
  80171c:	77 45                	ja     801763 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80171e:	83 ec 0c             	sub    $0xc,%esp
  801721:	ff 75 18             	pushl  0x18(%ebp)
  801724:	8b 45 14             	mov    0x14(%ebp),%eax
  801727:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80172a:	53                   	push   %ebx
  80172b:	ff 75 10             	pushl  0x10(%ebp)
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	ff 75 e4             	pushl  -0x1c(%ebp)
  801734:	ff 75 e0             	pushl  -0x20(%ebp)
  801737:	ff 75 dc             	pushl  -0x24(%ebp)
  80173a:	ff 75 d8             	pushl  -0x28(%ebp)
  80173d:	e8 2e 0a 00 00       	call   802170 <__udivdi3>
  801742:	83 c4 18             	add    $0x18,%esp
  801745:	52                   	push   %edx
  801746:	50                   	push   %eax
  801747:	89 f2                	mov    %esi,%edx
  801749:	89 f8                	mov    %edi,%eax
  80174b:	e8 9e ff ff ff       	call   8016ee <printnum>
  801750:	83 c4 20             	add    $0x20,%esp
  801753:	eb 18                	jmp    80176d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801755:	83 ec 08             	sub    $0x8,%esp
  801758:	56                   	push   %esi
  801759:	ff 75 18             	pushl  0x18(%ebp)
  80175c:	ff d7                	call   *%edi
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	eb 03                	jmp    801766 <printnum+0x78>
  801763:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801766:	83 eb 01             	sub    $0x1,%ebx
  801769:	85 db                	test   %ebx,%ebx
  80176b:	7f e8                	jg     801755 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80176d:	83 ec 08             	sub    $0x8,%esp
  801770:	56                   	push   %esi
  801771:	83 ec 04             	sub    $0x4,%esp
  801774:	ff 75 e4             	pushl  -0x1c(%ebp)
  801777:	ff 75 e0             	pushl  -0x20(%ebp)
  80177a:	ff 75 dc             	pushl  -0x24(%ebp)
  80177d:	ff 75 d8             	pushl  -0x28(%ebp)
  801780:	e8 1b 0b 00 00       	call   8022a0 <__umoddi3>
  801785:	83 c4 14             	add    $0x14,%esp
  801788:	0f be 80 d3 25 80 00 	movsbl 0x8025d3(%eax),%eax
  80178f:	50                   	push   %eax
  801790:	ff d7                	call   *%edi
}
  801792:	83 c4 10             	add    $0x10,%esp
  801795:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801798:	5b                   	pop    %ebx
  801799:	5e                   	pop    %esi
  80179a:	5f                   	pop    %edi
  80179b:	5d                   	pop    %ebp
  80179c:	c3                   	ret    

0080179d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8017a0:	83 fa 01             	cmp    $0x1,%edx
  8017a3:	7e 0e                	jle    8017b3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8017a5:	8b 10                	mov    (%eax),%edx
  8017a7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8017aa:	89 08                	mov    %ecx,(%eax)
  8017ac:	8b 02                	mov    (%edx),%eax
  8017ae:	8b 52 04             	mov    0x4(%edx),%edx
  8017b1:	eb 22                	jmp    8017d5 <getuint+0x38>
	else if (lflag)
  8017b3:	85 d2                	test   %edx,%edx
  8017b5:	74 10                	je     8017c7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8017b7:	8b 10                	mov    (%eax),%edx
  8017b9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017bc:	89 08                	mov    %ecx,(%eax)
  8017be:	8b 02                	mov    (%edx),%eax
  8017c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c5:	eb 0e                	jmp    8017d5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8017c7:	8b 10                	mov    (%eax),%edx
  8017c9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017cc:	89 08                	mov    %ecx,(%eax)
  8017ce:	8b 02                	mov    (%edx),%eax
  8017d0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017d5:	5d                   	pop    %ebp
  8017d6:	c3                   	ret    

008017d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017dd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017e1:	8b 10                	mov    (%eax),%edx
  8017e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8017e6:	73 0a                	jae    8017f2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8017e8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017eb:	89 08                	mov    %ecx,(%eax)
  8017ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f0:	88 02                	mov    %al,(%edx)
}
  8017f2:	5d                   	pop    %ebp
  8017f3:	c3                   	ret    

008017f4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017fd:	50                   	push   %eax
  8017fe:	ff 75 10             	pushl  0x10(%ebp)
  801801:	ff 75 0c             	pushl  0xc(%ebp)
  801804:	ff 75 08             	pushl  0x8(%ebp)
  801807:	e8 05 00 00 00       	call   801811 <vprintfmt>
	va_end(ap);
}
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	c9                   	leave  
  801810:	c3                   	ret    

00801811 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	57                   	push   %edi
  801815:	56                   	push   %esi
  801816:	53                   	push   %ebx
  801817:	83 ec 2c             	sub    $0x2c,%esp
  80181a:	8b 75 08             	mov    0x8(%ebp),%esi
  80181d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801820:	8b 7d 10             	mov    0x10(%ebp),%edi
  801823:	eb 12                	jmp    801837 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801825:	85 c0                	test   %eax,%eax
  801827:	0f 84 89 03 00 00    	je     801bb6 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80182d:	83 ec 08             	sub    $0x8,%esp
  801830:	53                   	push   %ebx
  801831:	50                   	push   %eax
  801832:	ff d6                	call   *%esi
  801834:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801837:	83 c7 01             	add    $0x1,%edi
  80183a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80183e:	83 f8 25             	cmp    $0x25,%eax
  801841:	75 e2                	jne    801825 <vprintfmt+0x14>
  801843:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801847:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80184e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801855:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80185c:	ba 00 00 00 00       	mov    $0x0,%edx
  801861:	eb 07                	jmp    80186a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801863:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801866:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186a:	8d 47 01             	lea    0x1(%edi),%eax
  80186d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801870:	0f b6 07             	movzbl (%edi),%eax
  801873:	0f b6 c8             	movzbl %al,%ecx
  801876:	83 e8 23             	sub    $0x23,%eax
  801879:	3c 55                	cmp    $0x55,%al
  80187b:	0f 87 1a 03 00 00    	ja     801b9b <vprintfmt+0x38a>
  801881:	0f b6 c0             	movzbl %al,%eax
  801884:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  80188b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80188e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801892:	eb d6                	jmp    80186a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801894:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801897:	b8 00 00 00 00       	mov    $0x0,%eax
  80189c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80189f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8018a2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8018a6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8018a9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8018ac:	83 fa 09             	cmp    $0x9,%edx
  8018af:	77 39                	ja     8018ea <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8018b1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8018b4:	eb e9                	jmp    80189f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8018b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b9:	8d 48 04             	lea    0x4(%eax),%ecx
  8018bc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8018bf:	8b 00                	mov    (%eax),%eax
  8018c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8018c7:	eb 27                	jmp    8018f0 <vprintfmt+0xdf>
  8018c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018d3:	0f 49 c8             	cmovns %eax,%ecx
  8018d6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018dc:	eb 8c                	jmp    80186a <vprintfmt+0x59>
  8018de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018e1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018e8:	eb 80                	jmp    80186a <vprintfmt+0x59>
  8018ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018ed:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018f4:	0f 89 70 ff ff ff    	jns    80186a <vprintfmt+0x59>
				width = precision, precision = -1;
  8018fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801900:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801907:	e9 5e ff ff ff       	jmp    80186a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80190c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80190f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801912:	e9 53 ff ff ff       	jmp    80186a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801917:	8b 45 14             	mov    0x14(%ebp),%eax
  80191a:	8d 50 04             	lea    0x4(%eax),%edx
  80191d:	89 55 14             	mov    %edx,0x14(%ebp)
  801920:	83 ec 08             	sub    $0x8,%esp
  801923:	53                   	push   %ebx
  801924:	ff 30                	pushl  (%eax)
  801926:	ff d6                	call   *%esi
			break;
  801928:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80192e:	e9 04 ff ff ff       	jmp    801837 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801933:	8b 45 14             	mov    0x14(%ebp),%eax
  801936:	8d 50 04             	lea    0x4(%eax),%edx
  801939:	89 55 14             	mov    %edx,0x14(%ebp)
  80193c:	8b 00                	mov    (%eax),%eax
  80193e:	99                   	cltd   
  80193f:	31 d0                	xor    %edx,%eax
  801941:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801943:	83 f8 0f             	cmp    $0xf,%eax
  801946:	7f 0b                	jg     801953 <vprintfmt+0x142>
  801948:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  80194f:	85 d2                	test   %edx,%edx
  801951:	75 18                	jne    80196b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801953:	50                   	push   %eax
  801954:	68 eb 25 80 00       	push   $0x8025eb
  801959:	53                   	push   %ebx
  80195a:	56                   	push   %esi
  80195b:	e8 94 fe ff ff       	call   8017f4 <printfmt>
  801960:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801963:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801966:	e9 cc fe ff ff       	jmp    801837 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80196b:	52                   	push   %edx
  80196c:	68 69 25 80 00       	push   $0x802569
  801971:	53                   	push   %ebx
  801972:	56                   	push   %esi
  801973:	e8 7c fe ff ff       	call   8017f4 <printfmt>
  801978:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80197b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80197e:	e9 b4 fe ff ff       	jmp    801837 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801983:	8b 45 14             	mov    0x14(%ebp),%eax
  801986:	8d 50 04             	lea    0x4(%eax),%edx
  801989:	89 55 14             	mov    %edx,0x14(%ebp)
  80198c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80198e:	85 ff                	test   %edi,%edi
  801990:	b8 e4 25 80 00       	mov    $0x8025e4,%eax
  801995:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801998:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80199c:	0f 8e 94 00 00 00    	jle    801a36 <vprintfmt+0x225>
  8019a2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8019a6:	0f 84 98 00 00 00    	je     801a44 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8019ac:	83 ec 08             	sub    $0x8,%esp
  8019af:	ff 75 d0             	pushl  -0x30(%ebp)
  8019b2:	57                   	push   %edi
  8019b3:	e8 86 02 00 00       	call   801c3e <strnlen>
  8019b8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8019bb:	29 c1                	sub    %eax,%ecx
  8019bd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8019c0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8019c3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8019c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019ca:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8019cd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019cf:	eb 0f                	jmp    8019e0 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8019d1:	83 ec 08             	sub    $0x8,%esp
  8019d4:	53                   	push   %ebx
  8019d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8019d8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019da:	83 ef 01             	sub    $0x1,%edi
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	85 ff                	test   %edi,%edi
  8019e2:	7f ed                	jg     8019d1 <vprintfmt+0x1c0>
  8019e4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019e7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019ea:	85 c9                	test   %ecx,%ecx
  8019ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f1:	0f 49 c1             	cmovns %ecx,%eax
  8019f4:	29 c1                	sub    %eax,%ecx
  8019f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8019f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019ff:	89 cb                	mov    %ecx,%ebx
  801a01:	eb 4d                	jmp    801a50 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a03:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a07:	74 1b                	je     801a24 <vprintfmt+0x213>
  801a09:	0f be c0             	movsbl %al,%eax
  801a0c:	83 e8 20             	sub    $0x20,%eax
  801a0f:	83 f8 5e             	cmp    $0x5e,%eax
  801a12:	76 10                	jbe    801a24 <vprintfmt+0x213>
					putch('?', putdat);
  801a14:	83 ec 08             	sub    $0x8,%esp
  801a17:	ff 75 0c             	pushl  0xc(%ebp)
  801a1a:	6a 3f                	push   $0x3f
  801a1c:	ff 55 08             	call   *0x8(%ebp)
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	eb 0d                	jmp    801a31 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801a24:	83 ec 08             	sub    $0x8,%esp
  801a27:	ff 75 0c             	pushl  0xc(%ebp)
  801a2a:	52                   	push   %edx
  801a2b:	ff 55 08             	call   *0x8(%ebp)
  801a2e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a31:	83 eb 01             	sub    $0x1,%ebx
  801a34:	eb 1a                	jmp    801a50 <vprintfmt+0x23f>
  801a36:	89 75 08             	mov    %esi,0x8(%ebp)
  801a39:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a3c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a3f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a42:	eb 0c                	jmp    801a50 <vprintfmt+0x23f>
  801a44:	89 75 08             	mov    %esi,0x8(%ebp)
  801a47:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a4a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a4d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a50:	83 c7 01             	add    $0x1,%edi
  801a53:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a57:	0f be d0             	movsbl %al,%edx
  801a5a:	85 d2                	test   %edx,%edx
  801a5c:	74 23                	je     801a81 <vprintfmt+0x270>
  801a5e:	85 f6                	test   %esi,%esi
  801a60:	78 a1                	js     801a03 <vprintfmt+0x1f2>
  801a62:	83 ee 01             	sub    $0x1,%esi
  801a65:	79 9c                	jns    801a03 <vprintfmt+0x1f2>
  801a67:	89 df                	mov    %ebx,%edi
  801a69:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a6f:	eb 18                	jmp    801a89 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a71:	83 ec 08             	sub    $0x8,%esp
  801a74:	53                   	push   %ebx
  801a75:	6a 20                	push   $0x20
  801a77:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a79:	83 ef 01             	sub    $0x1,%edi
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	eb 08                	jmp    801a89 <vprintfmt+0x278>
  801a81:	89 df                	mov    %ebx,%edi
  801a83:	8b 75 08             	mov    0x8(%ebp),%esi
  801a86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a89:	85 ff                	test   %edi,%edi
  801a8b:	7f e4                	jg     801a71 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a8d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a90:	e9 a2 fd ff ff       	jmp    801837 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a95:	83 fa 01             	cmp    $0x1,%edx
  801a98:	7e 16                	jle    801ab0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a9a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9d:	8d 50 08             	lea    0x8(%eax),%edx
  801aa0:	89 55 14             	mov    %edx,0x14(%ebp)
  801aa3:	8b 50 04             	mov    0x4(%eax),%edx
  801aa6:	8b 00                	mov    (%eax),%eax
  801aa8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801aae:	eb 32                	jmp    801ae2 <vprintfmt+0x2d1>
	else if (lflag)
  801ab0:	85 d2                	test   %edx,%edx
  801ab2:	74 18                	je     801acc <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801ab4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab7:	8d 50 04             	lea    0x4(%eax),%edx
  801aba:	89 55 14             	mov    %edx,0x14(%ebp)
  801abd:	8b 00                	mov    (%eax),%eax
  801abf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ac2:	89 c1                	mov    %eax,%ecx
  801ac4:	c1 f9 1f             	sar    $0x1f,%ecx
  801ac7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801aca:	eb 16                	jmp    801ae2 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801acc:	8b 45 14             	mov    0x14(%ebp),%eax
  801acf:	8d 50 04             	lea    0x4(%eax),%edx
  801ad2:	89 55 14             	mov    %edx,0x14(%ebp)
  801ad5:	8b 00                	mov    (%eax),%eax
  801ad7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ada:	89 c1                	mov    %eax,%ecx
  801adc:	c1 f9 1f             	sar    $0x1f,%ecx
  801adf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ae2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ae5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801ae8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801aed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801af1:	79 74                	jns    801b67 <vprintfmt+0x356>
				putch('-', putdat);
  801af3:	83 ec 08             	sub    $0x8,%esp
  801af6:	53                   	push   %ebx
  801af7:	6a 2d                	push   $0x2d
  801af9:	ff d6                	call   *%esi
				num = -(long long) num;
  801afb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801afe:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b01:	f7 d8                	neg    %eax
  801b03:	83 d2 00             	adc    $0x0,%edx
  801b06:	f7 da                	neg    %edx
  801b08:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801b0b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801b10:	eb 55                	jmp    801b67 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b12:	8d 45 14             	lea    0x14(%ebp),%eax
  801b15:	e8 83 fc ff ff       	call   80179d <getuint>
			base = 10;
  801b1a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801b1f:	eb 46                	jmp    801b67 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801b21:	8d 45 14             	lea    0x14(%ebp),%eax
  801b24:	e8 74 fc ff ff       	call   80179d <getuint>
			base = 8;
  801b29:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b2e:	eb 37                	jmp    801b67 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b30:	83 ec 08             	sub    $0x8,%esp
  801b33:	53                   	push   %ebx
  801b34:	6a 30                	push   $0x30
  801b36:	ff d6                	call   *%esi
			putch('x', putdat);
  801b38:	83 c4 08             	add    $0x8,%esp
  801b3b:	53                   	push   %ebx
  801b3c:	6a 78                	push   $0x78
  801b3e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b40:	8b 45 14             	mov    0x14(%ebp),%eax
  801b43:	8d 50 04             	lea    0x4(%eax),%edx
  801b46:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b49:	8b 00                	mov    (%eax),%eax
  801b4b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b50:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b53:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b58:	eb 0d                	jmp    801b67 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b5a:	8d 45 14             	lea    0x14(%ebp),%eax
  801b5d:	e8 3b fc ff ff       	call   80179d <getuint>
			base = 16;
  801b62:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b67:	83 ec 0c             	sub    $0xc,%esp
  801b6a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b6e:	57                   	push   %edi
  801b6f:	ff 75 e0             	pushl  -0x20(%ebp)
  801b72:	51                   	push   %ecx
  801b73:	52                   	push   %edx
  801b74:	50                   	push   %eax
  801b75:	89 da                	mov    %ebx,%edx
  801b77:	89 f0                	mov    %esi,%eax
  801b79:	e8 70 fb ff ff       	call   8016ee <printnum>
			break;
  801b7e:	83 c4 20             	add    $0x20,%esp
  801b81:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b84:	e9 ae fc ff ff       	jmp    801837 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b89:	83 ec 08             	sub    $0x8,%esp
  801b8c:	53                   	push   %ebx
  801b8d:	51                   	push   %ecx
  801b8e:	ff d6                	call   *%esi
			break;
  801b90:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b93:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b96:	e9 9c fc ff ff       	jmp    801837 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b9b:	83 ec 08             	sub    $0x8,%esp
  801b9e:	53                   	push   %ebx
  801b9f:	6a 25                	push   $0x25
  801ba1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ba3:	83 c4 10             	add    $0x10,%esp
  801ba6:	eb 03                	jmp    801bab <vprintfmt+0x39a>
  801ba8:	83 ef 01             	sub    $0x1,%edi
  801bab:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801baf:	75 f7                	jne    801ba8 <vprintfmt+0x397>
  801bb1:	e9 81 fc ff ff       	jmp    801837 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5f                   	pop    %edi
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    

00801bbe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	83 ec 18             	sub    $0x18,%esp
  801bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801bca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801bcd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801bd1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801bd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	74 26                	je     801c05 <vsnprintf+0x47>
  801bdf:	85 d2                	test   %edx,%edx
  801be1:	7e 22                	jle    801c05 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801be3:	ff 75 14             	pushl  0x14(%ebp)
  801be6:	ff 75 10             	pushl  0x10(%ebp)
  801be9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bec:	50                   	push   %eax
  801bed:	68 d7 17 80 00       	push   $0x8017d7
  801bf2:	e8 1a fc ff ff       	call   801811 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bf7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bfa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	eb 05                	jmp    801c0a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c12:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c15:	50                   	push   %eax
  801c16:	ff 75 10             	pushl  0x10(%ebp)
  801c19:	ff 75 0c             	pushl  0xc(%ebp)
  801c1c:	ff 75 08             	pushl  0x8(%ebp)
  801c1f:	e8 9a ff ff ff       	call   801bbe <vsnprintf>
	va_end(ap);

	return rc;
}
  801c24:	c9                   	leave  
  801c25:	c3                   	ret    

00801c26 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
  801c29:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c31:	eb 03                	jmp    801c36 <strlen+0x10>
		n++;
  801c33:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c36:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c3a:	75 f7                	jne    801c33 <strlen+0xd>
		n++;
	return n;
}
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c44:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c47:	ba 00 00 00 00       	mov    $0x0,%edx
  801c4c:	eb 03                	jmp    801c51 <strnlen+0x13>
		n++;
  801c4e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c51:	39 c2                	cmp    %eax,%edx
  801c53:	74 08                	je     801c5d <strnlen+0x1f>
  801c55:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c59:	75 f3                	jne    801c4e <strnlen+0x10>
  801c5b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c5d:	5d                   	pop    %ebp
  801c5e:	c3                   	ret    

00801c5f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	53                   	push   %ebx
  801c63:	8b 45 08             	mov    0x8(%ebp),%eax
  801c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c69:	89 c2                	mov    %eax,%edx
  801c6b:	83 c2 01             	add    $0x1,%edx
  801c6e:	83 c1 01             	add    $0x1,%ecx
  801c71:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c75:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c78:	84 db                	test   %bl,%bl
  801c7a:	75 ef                	jne    801c6b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c7c:	5b                   	pop    %ebx
  801c7d:	5d                   	pop    %ebp
  801c7e:	c3                   	ret    

00801c7f <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	53                   	push   %ebx
  801c83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c86:	53                   	push   %ebx
  801c87:	e8 9a ff ff ff       	call   801c26 <strlen>
  801c8c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c8f:	ff 75 0c             	pushl  0xc(%ebp)
  801c92:	01 d8                	add    %ebx,%eax
  801c94:	50                   	push   %eax
  801c95:	e8 c5 ff ff ff       	call   801c5f <strcpy>
	return dst;
}
  801c9a:	89 d8                	mov    %ebx,%eax
  801c9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c9f:	c9                   	leave  
  801ca0:	c3                   	ret    

00801ca1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	56                   	push   %esi
  801ca5:	53                   	push   %ebx
  801ca6:	8b 75 08             	mov    0x8(%ebp),%esi
  801ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cac:	89 f3                	mov    %esi,%ebx
  801cae:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801cb1:	89 f2                	mov    %esi,%edx
  801cb3:	eb 0f                	jmp    801cc4 <strncpy+0x23>
		*dst++ = *src;
  801cb5:	83 c2 01             	add    $0x1,%edx
  801cb8:	0f b6 01             	movzbl (%ecx),%eax
  801cbb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801cbe:	80 39 01             	cmpb   $0x1,(%ecx)
  801cc1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801cc4:	39 da                	cmp    %ebx,%edx
  801cc6:	75 ed                	jne    801cb5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801cc8:	89 f0                	mov    %esi,%eax
  801cca:	5b                   	pop    %ebx
  801ccb:	5e                   	pop    %esi
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    

00801cce <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	56                   	push   %esi
  801cd2:	53                   	push   %ebx
  801cd3:	8b 75 08             	mov    0x8(%ebp),%esi
  801cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd9:	8b 55 10             	mov    0x10(%ebp),%edx
  801cdc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801cde:	85 d2                	test   %edx,%edx
  801ce0:	74 21                	je     801d03 <strlcpy+0x35>
  801ce2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801ce6:	89 f2                	mov    %esi,%edx
  801ce8:	eb 09                	jmp    801cf3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801cea:	83 c2 01             	add    $0x1,%edx
  801ced:	83 c1 01             	add    $0x1,%ecx
  801cf0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801cf3:	39 c2                	cmp    %eax,%edx
  801cf5:	74 09                	je     801d00 <strlcpy+0x32>
  801cf7:	0f b6 19             	movzbl (%ecx),%ebx
  801cfa:	84 db                	test   %bl,%bl
  801cfc:	75 ec                	jne    801cea <strlcpy+0x1c>
  801cfe:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801d00:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801d03:	29 f0                	sub    %esi,%eax
}
  801d05:	5b                   	pop    %ebx
  801d06:	5e                   	pop    %esi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    

00801d09 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d0f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801d12:	eb 06                	jmp    801d1a <strcmp+0x11>
		p++, q++;
  801d14:	83 c1 01             	add    $0x1,%ecx
  801d17:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801d1a:	0f b6 01             	movzbl (%ecx),%eax
  801d1d:	84 c0                	test   %al,%al
  801d1f:	74 04                	je     801d25 <strcmp+0x1c>
  801d21:	3a 02                	cmp    (%edx),%al
  801d23:	74 ef                	je     801d14 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801d25:	0f b6 c0             	movzbl %al,%eax
  801d28:	0f b6 12             	movzbl (%edx),%edx
  801d2b:	29 d0                	sub    %edx,%eax
}
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    

00801d2f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	53                   	push   %ebx
  801d33:	8b 45 08             	mov    0x8(%ebp),%eax
  801d36:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d39:	89 c3                	mov    %eax,%ebx
  801d3b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d3e:	eb 06                	jmp    801d46 <strncmp+0x17>
		n--, p++, q++;
  801d40:	83 c0 01             	add    $0x1,%eax
  801d43:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d46:	39 d8                	cmp    %ebx,%eax
  801d48:	74 15                	je     801d5f <strncmp+0x30>
  801d4a:	0f b6 08             	movzbl (%eax),%ecx
  801d4d:	84 c9                	test   %cl,%cl
  801d4f:	74 04                	je     801d55 <strncmp+0x26>
  801d51:	3a 0a                	cmp    (%edx),%cl
  801d53:	74 eb                	je     801d40 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d55:	0f b6 00             	movzbl (%eax),%eax
  801d58:	0f b6 12             	movzbl (%edx),%edx
  801d5b:	29 d0                	sub    %edx,%eax
  801d5d:	eb 05                	jmp    801d64 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d5f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d64:	5b                   	pop    %ebx
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d71:	eb 07                	jmp    801d7a <strchr+0x13>
		if (*s == c)
  801d73:	38 ca                	cmp    %cl,%dl
  801d75:	74 0f                	je     801d86 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d77:	83 c0 01             	add    $0x1,%eax
  801d7a:	0f b6 10             	movzbl (%eax),%edx
  801d7d:	84 d2                	test   %dl,%dl
  801d7f:	75 f2                	jne    801d73 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    

00801d88 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d92:	eb 03                	jmp    801d97 <strfind+0xf>
  801d94:	83 c0 01             	add    $0x1,%eax
  801d97:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d9a:	38 ca                	cmp    %cl,%dl
  801d9c:	74 04                	je     801da2 <strfind+0x1a>
  801d9e:	84 d2                	test   %dl,%dl
  801da0:	75 f2                	jne    801d94 <strfind+0xc>
			break;
	return (char *) s;
}
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	57                   	push   %edi
  801da8:	56                   	push   %esi
  801da9:	53                   	push   %ebx
  801daa:	8b 7d 08             	mov    0x8(%ebp),%edi
  801dad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801db0:	85 c9                	test   %ecx,%ecx
  801db2:	74 36                	je     801dea <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801db4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801dba:	75 28                	jne    801de4 <memset+0x40>
  801dbc:	f6 c1 03             	test   $0x3,%cl
  801dbf:	75 23                	jne    801de4 <memset+0x40>
		c &= 0xFF;
  801dc1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801dc5:	89 d3                	mov    %edx,%ebx
  801dc7:	c1 e3 08             	shl    $0x8,%ebx
  801dca:	89 d6                	mov    %edx,%esi
  801dcc:	c1 e6 18             	shl    $0x18,%esi
  801dcf:	89 d0                	mov    %edx,%eax
  801dd1:	c1 e0 10             	shl    $0x10,%eax
  801dd4:	09 f0                	or     %esi,%eax
  801dd6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801dd8:	89 d8                	mov    %ebx,%eax
  801dda:	09 d0                	or     %edx,%eax
  801ddc:	c1 e9 02             	shr    $0x2,%ecx
  801ddf:	fc                   	cld    
  801de0:	f3 ab                	rep stos %eax,%es:(%edi)
  801de2:	eb 06                	jmp    801dea <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801de4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de7:	fc                   	cld    
  801de8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801dea:	89 f8                	mov    %edi,%eax
  801dec:	5b                   	pop    %ebx
  801ded:	5e                   	pop    %esi
  801dee:	5f                   	pop    %edi
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	57                   	push   %edi
  801df5:	56                   	push   %esi
  801df6:	8b 45 08             	mov    0x8(%ebp),%eax
  801df9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dfc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801dff:	39 c6                	cmp    %eax,%esi
  801e01:	73 35                	jae    801e38 <memmove+0x47>
  801e03:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e06:	39 d0                	cmp    %edx,%eax
  801e08:	73 2e                	jae    801e38 <memmove+0x47>
		s += n;
		d += n;
  801e0a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e0d:	89 d6                	mov    %edx,%esi
  801e0f:	09 fe                	or     %edi,%esi
  801e11:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e17:	75 13                	jne    801e2c <memmove+0x3b>
  801e19:	f6 c1 03             	test   $0x3,%cl
  801e1c:	75 0e                	jne    801e2c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801e1e:	83 ef 04             	sub    $0x4,%edi
  801e21:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e24:	c1 e9 02             	shr    $0x2,%ecx
  801e27:	fd                   	std    
  801e28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e2a:	eb 09                	jmp    801e35 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e2c:	83 ef 01             	sub    $0x1,%edi
  801e2f:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e32:	fd                   	std    
  801e33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e35:	fc                   	cld    
  801e36:	eb 1d                	jmp    801e55 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e38:	89 f2                	mov    %esi,%edx
  801e3a:	09 c2                	or     %eax,%edx
  801e3c:	f6 c2 03             	test   $0x3,%dl
  801e3f:	75 0f                	jne    801e50 <memmove+0x5f>
  801e41:	f6 c1 03             	test   $0x3,%cl
  801e44:	75 0a                	jne    801e50 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e46:	c1 e9 02             	shr    $0x2,%ecx
  801e49:	89 c7                	mov    %eax,%edi
  801e4b:	fc                   	cld    
  801e4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e4e:	eb 05                	jmp    801e55 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e50:	89 c7                	mov    %eax,%edi
  801e52:	fc                   	cld    
  801e53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e55:	5e                   	pop    %esi
  801e56:	5f                   	pop    %edi
  801e57:	5d                   	pop    %ebp
  801e58:	c3                   	ret    

00801e59 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e5c:	ff 75 10             	pushl  0x10(%ebp)
  801e5f:	ff 75 0c             	pushl  0xc(%ebp)
  801e62:	ff 75 08             	pushl  0x8(%ebp)
  801e65:	e8 87 ff ff ff       	call   801df1 <memmove>
}
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    

00801e6c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	56                   	push   %esi
  801e70:	53                   	push   %ebx
  801e71:	8b 45 08             	mov    0x8(%ebp),%eax
  801e74:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e77:	89 c6                	mov    %eax,%esi
  801e79:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e7c:	eb 1a                	jmp    801e98 <memcmp+0x2c>
		if (*s1 != *s2)
  801e7e:	0f b6 08             	movzbl (%eax),%ecx
  801e81:	0f b6 1a             	movzbl (%edx),%ebx
  801e84:	38 d9                	cmp    %bl,%cl
  801e86:	74 0a                	je     801e92 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e88:	0f b6 c1             	movzbl %cl,%eax
  801e8b:	0f b6 db             	movzbl %bl,%ebx
  801e8e:	29 d8                	sub    %ebx,%eax
  801e90:	eb 0f                	jmp    801ea1 <memcmp+0x35>
		s1++, s2++;
  801e92:	83 c0 01             	add    $0x1,%eax
  801e95:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e98:	39 f0                	cmp    %esi,%eax
  801e9a:	75 e2                	jne    801e7e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ea1:	5b                   	pop    %ebx
  801ea2:	5e                   	pop    %esi
  801ea3:	5d                   	pop    %ebp
  801ea4:	c3                   	ret    

00801ea5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	53                   	push   %ebx
  801ea9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801eac:	89 c1                	mov    %eax,%ecx
  801eae:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801eb1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801eb5:	eb 0a                	jmp    801ec1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801eb7:	0f b6 10             	movzbl (%eax),%edx
  801eba:	39 da                	cmp    %ebx,%edx
  801ebc:	74 07                	je     801ec5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ebe:	83 c0 01             	add    $0x1,%eax
  801ec1:	39 c8                	cmp    %ecx,%eax
  801ec3:	72 f2                	jb     801eb7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801ec5:	5b                   	pop    %ebx
  801ec6:	5d                   	pop    %ebp
  801ec7:	c3                   	ret    

00801ec8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	57                   	push   %edi
  801ecc:	56                   	push   %esi
  801ecd:	53                   	push   %ebx
  801ece:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ed4:	eb 03                	jmp    801ed9 <strtol+0x11>
		s++;
  801ed6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ed9:	0f b6 01             	movzbl (%ecx),%eax
  801edc:	3c 20                	cmp    $0x20,%al
  801ede:	74 f6                	je     801ed6 <strtol+0xe>
  801ee0:	3c 09                	cmp    $0x9,%al
  801ee2:	74 f2                	je     801ed6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ee4:	3c 2b                	cmp    $0x2b,%al
  801ee6:	75 0a                	jne    801ef2 <strtol+0x2a>
		s++;
  801ee8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801eeb:	bf 00 00 00 00       	mov    $0x0,%edi
  801ef0:	eb 11                	jmp    801f03 <strtol+0x3b>
  801ef2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ef7:	3c 2d                	cmp    $0x2d,%al
  801ef9:	75 08                	jne    801f03 <strtol+0x3b>
		s++, neg = 1;
  801efb:	83 c1 01             	add    $0x1,%ecx
  801efe:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f03:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f09:	75 15                	jne    801f20 <strtol+0x58>
  801f0b:	80 39 30             	cmpb   $0x30,(%ecx)
  801f0e:	75 10                	jne    801f20 <strtol+0x58>
  801f10:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f14:	75 7c                	jne    801f92 <strtol+0xca>
		s += 2, base = 16;
  801f16:	83 c1 02             	add    $0x2,%ecx
  801f19:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f1e:	eb 16                	jmp    801f36 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801f20:	85 db                	test   %ebx,%ebx
  801f22:	75 12                	jne    801f36 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f24:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f29:	80 39 30             	cmpb   $0x30,(%ecx)
  801f2c:	75 08                	jne    801f36 <strtol+0x6e>
		s++, base = 8;
  801f2e:	83 c1 01             	add    $0x1,%ecx
  801f31:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f36:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f3e:	0f b6 11             	movzbl (%ecx),%edx
  801f41:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f44:	89 f3                	mov    %esi,%ebx
  801f46:	80 fb 09             	cmp    $0x9,%bl
  801f49:	77 08                	ja     801f53 <strtol+0x8b>
			dig = *s - '0';
  801f4b:	0f be d2             	movsbl %dl,%edx
  801f4e:	83 ea 30             	sub    $0x30,%edx
  801f51:	eb 22                	jmp    801f75 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f53:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f56:	89 f3                	mov    %esi,%ebx
  801f58:	80 fb 19             	cmp    $0x19,%bl
  801f5b:	77 08                	ja     801f65 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f5d:	0f be d2             	movsbl %dl,%edx
  801f60:	83 ea 57             	sub    $0x57,%edx
  801f63:	eb 10                	jmp    801f75 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f65:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f68:	89 f3                	mov    %esi,%ebx
  801f6a:	80 fb 19             	cmp    $0x19,%bl
  801f6d:	77 16                	ja     801f85 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f6f:	0f be d2             	movsbl %dl,%edx
  801f72:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f75:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f78:	7d 0b                	jge    801f85 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f7a:	83 c1 01             	add    $0x1,%ecx
  801f7d:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f81:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f83:	eb b9                	jmp    801f3e <strtol+0x76>

	if (endptr)
  801f85:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f89:	74 0d                	je     801f98 <strtol+0xd0>
		*endptr = (char *) s;
  801f8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f8e:	89 0e                	mov    %ecx,(%esi)
  801f90:	eb 06                	jmp    801f98 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f92:	85 db                	test   %ebx,%ebx
  801f94:	74 98                	je     801f2e <strtol+0x66>
  801f96:	eb 9e                	jmp    801f36 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f98:	89 c2                	mov    %eax,%edx
  801f9a:	f7 da                	neg    %edx
  801f9c:	85 ff                	test   %edi,%edi
  801f9e:	0f 45 c2             	cmovne %edx,%eax
}
  801fa1:	5b                   	pop    %ebx
  801fa2:	5e                   	pop    %esi
  801fa3:	5f                   	pop    %edi
  801fa4:	5d                   	pop    %ebp
  801fa5:	c3                   	ret    

00801fa6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fa6:	55                   	push   %ebp
  801fa7:	89 e5                	mov    %esp,%ebp
  801fa9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fac:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fb3:	75 2a                	jne    801fdf <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801fb5:	83 ec 04             	sub    $0x4,%esp
  801fb8:	6a 07                	push   $0x7
  801fba:	68 00 f0 bf ee       	push   $0xeebff000
  801fbf:	6a 00                	push   $0x0
  801fc1:	e8 cd e1 ff ff       	call   800193 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	79 12                	jns    801fdf <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fcd:	50                   	push   %eax
  801fce:	68 bd 24 80 00       	push   $0x8024bd
  801fd3:	6a 23                	push   $0x23
  801fd5:	68 e0 28 80 00       	push   $0x8028e0
  801fda:	e8 22 f6 ff ff       	call   801601 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe2:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fe7:	83 ec 08             	sub    $0x8,%esp
  801fea:	68 e4 03 80 00       	push   $0x8003e4
  801fef:	6a 00                	push   $0x0
  801ff1:	e8 e8 e2 ff ff       	call   8002de <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801ff6:	83 c4 10             	add    $0x10,%esp
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	79 12                	jns    80200f <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801ffd:	50                   	push   %eax
  801ffe:	68 bd 24 80 00       	push   $0x8024bd
  802003:	6a 2c                	push   $0x2c
  802005:	68 e0 28 80 00       	push   $0x8028e0
  80200a:	e8 f2 f5 ff ff       	call   801601 <_panic>
	}
}
  80200f:	c9                   	leave  
  802010:	c3                   	ret    

00802011 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802011:	55                   	push   %ebp
  802012:	89 e5                	mov    %esp,%ebp
  802014:	56                   	push   %esi
  802015:	53                   	push   %ebx
  802016:	8b 75 08             	mov    0x8(%ebp),%esi
  802019:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80201f:	85 c0                	test   %eax,%eax
  802021:	75 12                	jne    802035 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802023:	83 ec 0c             	sub    $0xc,%esp
  802026:	68 00 00 c0 ee       	push   $0xeec00000
  80202b:	e8 13 e3 ff ff       	call   800343 <sys_ipc_recv>
  802030:	83 c4 10             	add    $0x10,%esp
  802033:	eb 0c                	jmp    802041 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802035:	83 ec 0c             	sub    $0xc,%esp
  802038:	50                   	push   %eax
  802039:	e8 05 e3 ff ff       	call   800343 <sys_ipc_recv>
  80203e:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802041:	85 f6                	test   %esi,%esi
  802043:	0f 95 c1             	setne  %cl
  802046:	85 db                	test   %ebx,%ebx
  802048:	0f 95 c2             	setne  %dl
  80204b:	84 d1                	test   %dl,%cl
  80204d:	74 09                	je     802058 <ipc_recv+0x47>
  80204f:	89 c2                	mov    %eax,%edx
  802051:	c1 ea 1f             	shr    $0x1f,%edx
  802054:	84 d2                	test   %dl,%dl
  802056:	75 2d                	jne    802085 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802058:	85 f6                	test   %esi,%esi
  80205a:	74 0d                	je     802069 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80205c:	a1 04 40 80 00       	mov    0x804004,%eax
  802061:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802067:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802069:	85 db                	test   %ebx,%ebx
  80206b:	74 0d                	je     80207a <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80206d:	a1 04 40 80 00       	mov    0x804004,%eax
  802072:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802078:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80207a:	a1 04 40 80 00       	mov    0x804004,%eax
  80207f:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802085:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802088:	5b                   	pop    %ebx
  802089:	5e                   	pop    %esi
  80208a:	5d                   	pop    %ebp
  80208b:	c3                   	ret    

0080208c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	57                   	push   %edi
  802090:	56                   	push   %esi
  802091:	53                   	push   %ebx
  802092:	83 ec 0c             	sub    $0xc,%esp
  802095:	8b 7d 08             	mov    0x8(%ebp),%edi
  802098:	8b 75 0c             	mov    0xc(%ebp),%esi
  80209b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80209e:	85 db                	test   %ebx,%ebx
  8020a0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020a5:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020a8:	ff 75 14             	pushl  0x14(%ebp)
  8020ab:	53                   	push   %ebx
  8020ac:	56                   	push   %esi
  8020ad:	57                   	push   %edi
  8020ae:	e8 6d e2 ff ff       	call   800320 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020b3:	89 c2                	mov    %eax,%edx
  8020b5:	c1 ea 1f             	shr    $0x1f,%edx
  8020b8:	83 c4 10             	add    $0x10,%esp
  8020bb:	84 d2                	test   %dl,%dl
  8020bd:	74 17                	je     8020d6 <ipc_send+0x4a>
  8020bf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020c2:	74 12                	je     8020d6 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020c4:	50                   	push   %eax
  8020c5:	68 ee 28 80 00       	push   $0x8028ee
  8020ca:	6a 47                	push   $0x47
  8020cc:	68 fc 28 80 00       	push   $0x8028fc
  8020d1:	e8 2b f5 ff ff       	call   801601 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020d6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d9:	75 07                	jne    8020e2 <ipc_send+0x56>
			sys_yield();
  8020db:	e8 94 e0 ff ff       	call   800174 <sys_yield>
  8020e0:	eb c6                	jmp    8020a8 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	75 c2                	jne    8020a8 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020e9:	5b                   	pop    %ebx
  8020ea:	5e                   	pop    %esi
  8020eb:	5f                   	pop    %edi
  8020ec:	5d                   	pop    %ebp
  8020ed:	c3                   	ret    

008020ee <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020f4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020f9:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8020ff:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802105:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  80210b:	39 ca                	cmp    %ecx,%edx
  80210d:	75 13                	jne    802122 <ipc_find_env+0x34>
			return envs[i].env_id;
  80210f:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802115:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80211a:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802120:	eb 0f                	jmp    802131 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802122:	83 c0 01             	add    $0x1,%eax
  802125:	3d 00 04 00 00       	cmp    $0x400,%eax
  80212a:	75 cd                	jne    8020f9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80212c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802131:	5d                   	pop    %ebp
  802132:	c3                   	ret    

00802133 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802133:	55                   	push   %ebp
  802134:	89 e5                	mov    %esp,%ebp
  802136:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802139:	89 d0                	mov    %edx,%eax
  80213b:	c1 e8 16             	shr    $0x16,%eax
  80213e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802145:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80214a:	f6 c1 01             	test   $0x1,%cl
  80214d:	74 1d                	je     80216c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80214f:	c1 ea 0c             	shr    $0xc,%edx
  802152:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802159:	f6 c2 01             	test   $0x1,%dl
  80215c:	74 0e                	je     80216c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80215e:	c1 ea 0c             	shr    $0xc,%edx
  802161:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802168:	ef 
  802169:	0f b7 c0             	movzwl %ax,%eax
}
  80216c:	5d                   	pop    %ebp
  80216d:	c3                   	ret    
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__udivdi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80217b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80217f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 f6                	test   %esi,%esi
  802189:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80218d:	89 ca                	mov    %ecx,%edx
  80218f:	89 f8                	mov    %edi,%eax
  802191:	75 3d                	jne    8021d0 <__udivdi3+0x60>
  802193:	39 cf                	cmp    %ecx,%edi
  802195:	0f 87 c5 00 00 00    	ja     802260 <__udivdi3+0xf0>
  80219b:	85 ff                	test   %edi,%edi
  80219d:	89 fd                	mov    %edi,%ebp
  80219f:	75 0b                	jne    8021ac <__udivdi3+0x3c>
  8021a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a6:	31 d2                	xor    %edx,%edx
  8021a8:	f7 f7                	div    %edi
  8021aa:	89 c5                	mov    %eax,%ebp
  8021ac:	89 c8                	mov    %ecx,%eax
  8021ae:	31 d2                	xor    %edx,%edx
  8021b0:	f7 f5                	div    %ebp
  8021b2:	89 c1                	mov    %eax,%ecx
  8021b4:	89 d8                	mov    %ebx,%eax
  8021b6:	89 cf                	mov    %ecx,%edi
  8021b8:	f7 f5                	div    %ebp
  8021ba:	89 c3                	mov    %eax,%ebx
  8021bc:	89 d8                	mov    %ebx,%eax
  8021be:	89 fa                	mov    %edi,%edx
  8021c0:	83 c4 1c             	add    $0x1c,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	39 ce                	cmp    %ecx,%esi
  8021d2:	77 74                	ja     802248 <__udivdi3+0xd8>
  8021d4:	0f bd fe             	bsr    %esi,%edi
  8021d7:	83 f7 1f             	xor    $0x1f,%edi
  8021da:	0f 84 98 00 00 00    	je     802278 <__udivdi3+0x108>
  8021e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	89 c5                	mov    %eax,%ebp
  8021e9:	29 fb                	sub    %edi,%ebx
  8021eb:	d3 e6                	shl    %cl,%esi
  8021ed:	89 d9                	mov    %ebx,%ecx
  8021ef:	d3 ed                	shr    %cl,%ebp
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	d3 e0                	shl    %cl,%eax
  8021f5:	09 ee                	or     %ebp,%esi
  8021f7:	89 d9                	mov    %ebx,%ecx
  8021f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021fd:	89 d5                	mov    %edx,%ebp
  8021ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802203:	d3 ed                	shr    %cl,%ebp
  802205:	89 f9                	mov    %edi,%ecx
  802207:	d3 e2                	shl    %cl,%edx
  802209:	89 d9                	mov    %ebx,%ecx
  80220b:	d3 e8                	shr    %cl,%eax
  80220d:	09 c2                	or     %eax,%edx
  80220f:	89 d0                	mov    %edx,%eax
  802211:	89 ea                	mov    %ebp,%edx
  802213:	f7 f6                	div    %esi
  802215:	89 d5                	mov    %edx,%ebp
  802217:	89 c3                	mov    %eax,%ebx
  802219:	f7 64 24 0c          	mull   0xc(%esp)
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	72 10                	jb     802231 <__udivdi3+0xc1>
  802221:	8b 74 24 08          	mov    0x8(%esp),%esi
  802225:	89 f9                	mov    %edi,%ecx
  802227:	d3 e6                	shl    %cl,%esi
  802229:	39 c6                	cmp    %eax,%esi
  80222b:	73 07                	jae    802234 <__udivdi3+0xc4>
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	75 03                	jne    802234 <__udivdi3+0xc4>
  802231:	83 eb 01             	sub    $0x1,%ebx
  802234:	31 ff                	xor    %edi,%edi
  802236:	89 d8                	mov    %ebx,%eax
  802238:	89 fa                	mov    %edi,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	31 ff                	xor    %edi,%edi
  80224a:	31 db                	xor    %ebx,%ebx
  80224c:	89 d8                	mov    %ebx,%eax
  80224e:	89 fa                	mov    %edi,%edx
  802250:	83 c4 1c             	add    $0x1c,%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    
  802258:	90                   	nop
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	89 d8                	mov    %ebx,%eax
  802262:	f7 f7                	div    %edi
  802264:	31 ff                	xor    %edi,%edi
  802266:	89 c3                	mov    %eax,%ebx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 fa                	mov    %edi,%edx
  80226c:	83 c4 1c             	add    $0x1c,%esp
  80226f:	5b                   	pop    %ebx
  802270:	5e                   	pop    %esi
  802271:	5f                   	pop    %edi
  802272:	5d                   	pop    %ebp
  802273:	c3                   	ret    
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	39 ce                	cmp    %ecx,%esi
  80227a:	72 0c                	jb     802288 <__udivdi3+0x118>
  80227c:	31 db                	xor    %ebx,%ebx
  80227e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802282:	0f 87 34 ff ff ff    	ja     8021bc <__udivdi3+0x4c>
  802288:	bb 01 00 00 00       	mov    $0x1,%ebx
  80228d:	e9 2a ff ff ff       	jmp    8021bc <__udivdi3+0x4c>
  802292:	66 90                	xchg   %ax,%ax
  802294:	66 90                	xchg   %ax,%ax
  802296:	66 90                	xchg   %ax,%ax
  802298:	66 90                	xchg   %ax,%ax
  80229a:	66 90                	xchg   %ax,%ax
  80229c:	66 90                	xchg   %ax,%ax
  80229e:	66 90                	xchg   %ax,%ax

008022a0 <__umoddi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	53                   	push   %ebx
  8022a4:	83 ec 1c             	sub    $0x1c,%esp
  8022a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022b7:	85 d2                	test   %edx,%edx
  8022b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022c1:	89 f3                	mov    %esi,%ebx
  8022c3:	89 3c 24             	mov    %edi,(%esp)
  8022c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ca:	75 1c                	jne    8022e8 <__umoddi3+0x48>
  8022cc:	39 f7                	cmp    %esi,%edi
  8022ce:	76 50                	jbe    802320 <__umoddi3+0x80>
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	f7 f7                	div    %edi
  8022d6:	89 d0                	mov    %edx,%eax
  8022d8:	31 d2                	xor    %edx,%edx
  8022da:	83 c4 1c             	add    $0x1c,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5f                   	pop    %edi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	39 f2                	cmp    %esi,%edx
  8022ea:	89 d0                	mov    %edx,%eax
  8022ec:	77 52                	ja     802340 <__umoddi3+0xa0>
  8022ee:	0f bd ea             	bsr    %edx,%ebp
  8022f1:	83 f5 1f             	xor    $0x1f,%ebp
  8022f4:	75 5a                	jne    802350 <__umoddi3+0xb0>
  8022f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022fa:	0f 82 e0 00 00 00    	jb     8023e0 <__umoddi3+0x140>
  802300:	39 0c 24             	cmp    %ecx,(%esp)
  802303:	0f 86 d7 00 00 00    	jbe    8023e0 <__umoddi3+0x140>
  802309:	8b 44 24 08          	mov    0x8(%esp),%eax
  80230d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802311:	83 c4 1c             	add    $0x1c,%esp
  802314:	5b                   	pop    %ebx
  802315:	5e                   	pop    %esi
  802316:	5f                   	pop    %edi
  802317:	5d                   	pop    %ebp
  802318:	c3                   	ret    
  802319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802320:	85 ff                	test   %edi,%edi
  802322:	89 fd                	mov    %edi,%ebp
  802324:	75 0b                	jne    802331 <__umoddi3+0x91>
  802326:	b8 01 00 00 00       	mov    $0x1,%eax
  80232b:	31 d2                	xor    %edx,%edx
  80232d:	f7 f7                	div    %edi
  80232f:	89 c5                	mov    %eax,%ebp
  802331:	89 f0                	mov    %esi,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f5                	div    %ebp
  802337:	89 c8                	mov    %ecx,%eax
  802339:	f7 f5                	div    %ebp
  80233b:	89 d0                	mov    %edx,%eax
  80233d:	eb 99                	jmp    8022d8 <__umoddi3+0x38>
  80233f:	90                   	nop
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	83 c4 1c             	add    $0x1c,%esp
  802347:	5b                   	pop    %ebx
  802348:	5e                   	pop    %esi
  802349:	5f                   	pop    %edi
  80234a:	5d                   	pop    %ebp
  80234b:	c3                   	ret    
  80234c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802350:	8b 34 24             	mov    (%esp),%esi
  802353:	bf 20 00 00 00       	mov    $0x20,%edi
  802358:	89 e9                	mov    %ebp,%ecx
  80235a:	29 ef                	sub    %ebp,%edi
  80235c:	d3 e0                	shl    %cl,%eax
  80235e:	89 f9                	mov    %edi,%ecx
  802360:	89 f2                	mov    %esi,%edx
  802362:	d3 ea                	shr    %cl,%edx
  802364:	89 e9                	mov    %ebp,%ecx
  802366:	09 c2                	or     %eax,%edx
  802368:	89 d8                	mov    %ebx,%eax
  80236a:	89 14 24             	mov    %edx,(%esp)
  80236d:	89 f2                	mov    %esi,%edx
  80236f:	d3 e2                	shl    %cl,%edx
  802371:	89 f9                	mov    %edi,%ecx
  802373:	89 54 24 04          	mov    %edx,0x4(%esp)
  802377:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80237b:	d3 e8                	shr    %cl,%eax
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	89 c6                	mov    %eax,%esi
  802381:	d3 e3                	shl    %cl,%ebx
  802383:	89 f9                	mov    %edi,%ecx
  802385:	89 d0                	mov    %edx,%eax
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	09 d8                	or     %ebx,%eax
  80238d:	89 d3                	mov    %edx,%ebx
  80238f:	89 f2                	mov    %esi,%edx
  802391:	f7 34 24             	divl   (%esp)
  802394:	89 d6                	mov    %edx,%esi
  802396:	d3 e3                	shl    %cl,%ebx
  802398:	f7 64 24 04          	mull   0x4(%esp)
  80239c:	39 d6                	cmp    %edx,%esi
  80239e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023a2:	89 d1                	mov    %edx,%ecx
  8023a4:	89 c3                	mov    %eax,%ebx
  8023a6:	72 08                	jb     8023b0 <__umoddi3+0x110>
  8023a8:	75 11                	jne    8023bb <__umoddi3+0x11b>
  8023aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023ae:	73 0b                	jae    8023bb <__umoddi3+0x11b>
  8023b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023b4:	1b 14 24             	sbb    (%esp),%edx
  8023b7:	89 d1                	mov    %edx,%ecx
  8023b9:	89 c3                	mov    %eax,%ebx
  8023bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023bf:	29 da                	sub    %ebx,%edx
  8023c1:	19 ce                	sbb    %ecx,%esi
  8023c3:	89 f9                	mov    %edi,%ecx
  8023c5:	89 f0                	mov    %esi,%eax
  8023c7:	d3 e0                	shl    %cl,%eax
  8023c9:	89 e9                	mov    %ebp,%ecx
  8023cb:	d3 ea                	shr    %cl,%edx
  8023cd:	89 e9                	mov    %ebp,%ecx
  8023cf:	d3 ee                	shr    %cl,%esi
  8023d1:	09 d0                	or     %edx,%eax
  8023d3:	89 f2                	mov    %esi,%edx
  8023d5:	83 c4 1c             	add    $0x1c,%esp
  8023d8:	5b                   	pop    %ebx
  8023d9:	5e                   	pop    %esi
  8023da:	5f                   	pop    %edi
  8023db:	5d                   	pop    %ebp
  8023dc:	c3                   	ret    
  8023dd:	8d 76 00             	lea    0x0(%esi),%esi
  8023e0:	29 f9                	sub    %edi,%ecx
  8023e2:	19 d6                	sbb    %edx,%esi
  8023e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023ec:	e9 18 ff ff ff       	jmp    802309 <__umoddi3+0x69>
