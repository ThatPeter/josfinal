
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 30 80 00 00 	movl   $0x802400,0x803000
  800040:	24 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 22 01 00 00       	call   80016a <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 f1 00 00 00       	call   80014b <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800065:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006a:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006f:	85 db                	test   %ebx,%ebx
  800071:	7e 07                	jle    80007a <libmain+0x30>
		binaryname = argv[0];
  800073:	8b 06                	mov    (%esi),%eax
  800075:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	56                   	push   %esi
  80007e:	53                   	push   %ebx
  80007f:	e8 af ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800084:	e8 2a 00 00 00       	call   8000b3 <exit>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    

00800093 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  800099:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  80009e:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000a0:	e8 a6 00 00 00       	call   80014b <sys_getenvid>
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	50                   	push   %eax
  8000a9:	e8 ec 02 00 00       	call   80039a <sys_thread_free>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	c9                   	leave  
  8000b2:	c3                   	ret    

008000b3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b9:	e8 e4 09 00 00       	call   800aa2 <close_all>
	sys_env_destroy(0);
  8000be:	83 ec 0c             	sub    $0xc,%esp
  8000c1:	6a 00                	push   $0x0
  8000c3:	e8 42 00 00 00       	call   80010a <sys_env_destroy>
}
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    

008000cd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	57                   	push   %edi
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000db:	8b 55 08             	mov    0x8(%ebp),%edx
  8000de:	89 c3                	mov    %eax,%ebx
  8000e0:	89 c7                	mov    %eax,%edi
  8000e2:	89 c6                	mov    %eax,%esi
  8000e4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fb:	89 d1                	mov    %edx,%ecx
  8000fd:	89 d3                	mov    %edx,%ebx
  8000ff:	89 d7                	mov    %edx,%edi
  800101:	89 d6                	mov    %edx,%esi
  800103:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800105:	5b                   	pop    %ebx
  800106:	5e                   	pop    %esi
  800107:	5f                   	pop    %edi
  800108:	5d                   	pop    %ebp
  800109:	c3                   	ret    

0080010a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	57                   	push   %edi
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800113:	b9 00 00 00 00       	mov    $0x0,%ecx
  800118:	b8 03 00 00 00       	mov    $0x3,%eax
  80011d:	8b 55 08             	mov    0x8(%ebp),%edx
  800120:	89 cb                	mov    %ecx,%ebx
  800122:	89 cf                	mov    %ecx,%edi
  800124:	89 ce                	mov    %ecx,%esi
  800126:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800128:	85 c0                	test   %eax,%eax
  80012a:	7e 17                	jle    800143 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012c:	83 ec 0c             	sub    $0xc,%esp
  80012f:	50                   	push   %eax
  800130:	6a 03                	push   $0x3
  800132:	68 0f 24 80 00       	push   $0x80240f
  800137:	6a 23                	push   $0x23
  800139:	68 2c 24 80 00       	push   $0x80242c
  80013e:	e8 90 14 00 00       	call   8015d3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800143:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 02 00 00 00       	mov    $0x2,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_yield>:

void
sys_yield(void)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800170:	ba 00 00 00 00       	mov    $0x0,%edx
  800175:	b8 0b 00 00 00       	mov    $0xb,%eax
  80017a:	89 d1                	mov    %edx,%ecx
  80017c:	89 d3                	mov    %edx,%ebx
  80017e:	89 d7                	mov    %edx,%edi
  800180:	89 d6                	mov    %edx,%esi
  800182:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800184:	5b                   	pop    %ebx
  800185:	5e                   	pop    %esi
  800186:	5f                   	pop    %edi
  800187:	5d                   	pop    %ebp
  800188:	c3                   	ret    

00800189 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800192:	be 00 00 00 00       	mov    $0x0,%esi
  800197:	b8 04 00 00 00       	mov    $0x4,%eax
  80019c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019f:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a5:	89 f7                	mov    %esi,%edi
  8001a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	7e 17                	jle    8001c4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ad:	83 ec 0c             	sub    $0xc,%esp
  8001b0:	50                   	push   %eax
  8001b1:	6a 04                	push   $0x4
  8001b3:	68 0f 24 80 00       	push   $0x80240f
  8001b8:	6a 23                	push   $0x23
  8001ba:	68 2c 24 80 00       	push   $0x80242c
  8001bf:	e8 0f 14 00 00       	call   8015d3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5f                   	pop    %edi
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001eb:	85 c0                	test   %eax,%eax
  8001ed:	7e 17                	jle    800206 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ef:	83 ec 0c             	sub    $0xc,%esp
  8001f2:	50                   	push   %eax
  8001f3:	6a 05                	push   $0x5
  8001f5:	68 0f 24 80 00       	push   $0x80240f
  8001fa:	6a 23                	push   $0x23
  8001fc:	68 2c 24 80 00       	push   $0x80242c
  800201:	e8 cd 13 00 00       	call   8015d3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5f                   	pop    %edi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	57                   	push   %edi
  800212:	56                   	push   %esi
  800213:	53                   	push   %ebx
  800214:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800217:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021c:	b8 06 00 00 00       	mov    $0x6,%eax
  800221:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800224:	8b 55 08             	mov    0x8(%ebp),%edx
  800227:	89 df                	mov    %ebx,%edi
  800229:	89 de                	mov    %ebx,%esi
  80022b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80022d:	85 c0                	test   %eax,%eax
  80022f:	7e 17                	jle    800248 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	50                   	push   %eax
  800235:	6a 06                	push   $0x6
  800237:	68 0f 24 80 00       	push   $0x80240f
  80023c:	6a 23                	push   $0x23
  80023e:	68 2c 24 80 00       	push   $0x80242c
  800243:	e8 8b 13 00 00       	call   8015d3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800259:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025e:	b8 08 00 00 00       	mov    $0x8,%eax
  800263:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800266:	8b 55 08             	mov    0x8(%ebp),%edx
  800269:	89 df                	mov    %ebx,%edi
  80026b:	89 de                	mov    %ebx,%esi
  80026d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80026f:	85 c0                	test   %eax,%eax
  800271:	7e 17                	jle    80028a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	50                   	push   %eax
  800277:	6a 08                	push   $0x8
  800279:	68 0f 24 80 00       	push   $0x80240f
  80027e:	6a 23                	push   $0x23
  800280:	68 2c 24 80 00       	push   $0x80242c
  800285:	e8 49 13 00 00       	call   8015d3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    

00800292 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	57                   	push   %edi
  800296:	56                   	push   %esi
  800297:	53                   	push   %ebx
  800298:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ab:	89 df                	mov    %ebx,%edi
  8002ad:	89 de                	mov    %ebx,%esi
  8002af:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002b1:	85 c0                	test   %eax,%eax
  8002b3:	7e 17                	jle    8002cc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b5:	83 ec 0c             	sub    $0xc,%esp
  8002b8:	50                   	push   %eax
  8002b9:	6a 09                	push   $0x9
  8002bb:	68 0f 24 80 00       	push   $0x80240f
  8002c0:	6a 23                	push   $0x23
  8002c2:	68 2c 24 80 00       	push   $0x80242c
  8002c7:	e8 07 13 00 00       	call   8015d3 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5e                   	pop    %esi
  8002d1:	5f                   	pop    %edi
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	57                   	push   %edi
  8002d8:	56                   	push   %esi
  8002d9:	53                   	push   %ebx
  8002da:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ed:	89 df                	mov    %ebx,%edi
  8002ef:	89 de                	mov    %ebx,%esi
  8002f1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	7e 17                	jle    80030e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f7:	83 ec 0c             	sub    $0xc,%esp
  8002fa:	50                   	push   %eax
  8002fb:	6a 0a                	push   $0xa
  8002fd:	68 0f 24 80 00       	push   $0x80240f
  800302:	6a 23                	push   $0x23
  800304:	68 2c 24 80 00       	push   $0x80242c
  800309:	e8 c5 12 00 00       	call   8015d3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80030e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	be 00 00 00 00       	mov    $0x0,%esi
  800321:	b8 0c 00 00 00       	mov    $0xc,%eax
  800326:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800332:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800334:	5b                   	pop    %ebx
  800335:	5e                   	pop    %esi
  800336:	5f                   	pop    %edi
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	57                   	push   %edi
  80033d:	56                   	push   %esi
  80033e:	53                   	push   %ebx
  80033f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800342:	b9 00 00 00 00       	mov    $0x0,%ecx
  800347:	b8 0d 00 00 00       	mov    $0xd,%eax
  80034c:	8b 55 08             	mov    0x8(%ebp),%edx
  80034f:	89 cb                	mov    %ecx,%ebx
  800351:	89 cf                	mov    %ecx,%edi
  800353:	89 ce                	mov    %ecx,%esi
  800355:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800357:	85 c0                	test   %eax,%eax
  800359:	7e 17                	jle    800372 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035b:	83 ec 0c             	sub    $0xc,%esp
  80035e:	50                   	push   %eax
  80035f:	6a 0d                	push   $0xd
  800361:	68 0f 24 80 00       	push   $0x80240f
  800366:	6a 23                	push   $0x23
  800368:	68 2c 24 80 00       	push   $0x80242c
  80036d:	e8 61 12 00 00       	call   8015d3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	57                   	push   %edi
  80037e:	56                   	push   %esi
  80037f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800380:	b9 00 00 00 00       	mov    $0x0,%ecx
  800385:	b8 0e 00 00 00       	mov    $0xe,%eax
  80038a:	8b 55 08             	mov    0x8(%ebp),%edx
  80038d:	89 cb                	mov    %ecx,%ebx
  80038f:	89 cf                	mov    %ecx,%edi
  800391:	89 ce                	mov    %ecx,%esi
  800393:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800395:	5b                   	pop    %ebx
  800396:	5e                   	pop    %esi
  800397:	5f                   	pop    %edi
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	57                   	push   %edi
  80039e:	56                   	push   %esi
  80039f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a5:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ad:	89 cb                	mov    %ecx,%ebx
  8003af:	89 cf                	mov    %ecx,%edi
  8003b1:	89 ce                	mov    %ecx,%esi
  8003b3:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003b5:	5b                   	pop    %ebx
  8003b6:	5e                   	pop    %esi
  8003b7:	5f                   	pop    %edi
  8003b8:	5d                   	pop    %ebp
  8003b9:	c3                   	ret    

008003ba <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	57                   	push   %edi
  8003be:	56                   	push   %esi
  8003bf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c5:	b8 10 00 00 00       	mov    $0x10,%eax
  8003ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8003cd:	89 cb                	mov    %ecx,%ebx
  8003cf:	89 cf                	mov    %ecx,%edi
  8003d1:	89 ce                	mov    %ecx,%esi
  8003d3:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  8003d5:	5b                   	pop    %ebx
  8003d6:	5e                   	pop    %esi
  8003d7:	5f                   	pop    %edi
  8003d8:	5d                   	pop    %ebp
  8003d9:	c3                   	ret    

008003da <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	53                   	push   %ebx
  8003de:	83 ec 04             	sub    $0x4,%esp
  8003e1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003e4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003e6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003ea:	74 11                	je     8003fd <pgfault+0x23>
  8003ec:	89 d8                	mov    %ebx,%eax
  8003ee:	c1 e8 0c             	shr    $0xc,%eax
  8003f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003f8:	f6 c4 08             	test   $0x8,%ah
  8003fb:	75 14                	jne    800411 <pgfault+0x37>
		panic("faulting access");
  8003fd:	83 ec 04             	sub    $0x4,%esp
  800400:	68 3a 24 80 00       	push   $0x80243a
  800405:	6a 1f                	push   $0x1f
  800407:	68 4a 24 80 00       	push   $0x80244a
  80040c:	e8 c2 11 00 00       	call   8015d3 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800411:	83 ec 04             	sub    $0x4,%esp
  800414:	6a 07                	push   $0x7
  800416:	68 00 f0 7f 00       	push   $0x7ff000
  80041b:	6a 00                	push   $0x0
  80041d:	e8 67 fd ff ff       	call   800189 <sys_page_alloc>
	if (r < 0) {
  800422:	83 c4 10             	add    $0x10,%esp
  800425:	85 c0                	test   %eax,%eax
  800427:	79 12                	jns    80043b <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800429:	50                   	push   %eax
  80042a:	68 55 24 80 00       	push   $0x802455
  80042f:	6a 2d                	push   $0x2d
  800431:	68 4a 24 80 00       	push   $0x80244a
  800436:	e8 98 11 00 00       	call   8015d3 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80043b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800441:	83 ec 04             	sub    $0x4,%esp
  800444:	68 00 10 00 00       	push   $0x1000
  800449:	53                   	push   %ebx
  80044a:	68 00 f0 7f 00       	push   $0x7ff000
  80044f:	e8 d7 19 00 00       	call   801e2b <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800454:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80045b:	53                   	push   %ebx
  80045c:	6a 00                	push   $0x0
  80045e:	68 00 f0 7f 00       	push   $0x7ff000
  800463:	6a 00                	push   $0x0
  800465:	e8 62 fd ff ff       	call   8001cc <sys_page_map>
	if (r < 0) {
  80046a:	83 c4 20             	add    $0x20,%esp
  80046d:	85 c0                	test   %eax,%eax
  80046f:	79 12                	jns    800483 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800471:	50                   	push   %eax
  800472:	68 55 24 80 00       	push   $0x802455
  800477:	6a 34                	push   $0x34
  800479:	68 4a 24 80 00       	push   $0x80244a
  80047e:	e8 50 11 00 00       	call   8015d3 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	68 00 f0 7f 00       	push   $0x7ff000
  80048b:	6a 00                	push   $0x0
  80048d:	e8 7c fd ff ff       	call   80020e <sys_page_unmap>
	if (r < 0) {
  800492:	83 c4 10             	add    $0x10,%esp
  800495:	85 c0                	test   %eax,%eax
  800497:	79 12                	jns    8004ab <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800499:	50                   	push   %eax
  80049a:	68 55 24 80 00       	push   $0x802455
  80049f:	6a 38                	push   $0x38
  8004a1:	68 4a 24 80 00       	push   $0x80244a
  8004a6:	e8 28 11 00 00       	call   8015d3 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8004ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ae:	c9                   	leave  
  8004af:	c3                   	ret    

008004b0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	57                   	push   %edi
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8004b9:	68 da 03 80 00       	push   $0x8003da
  8004be:	e8 b5 1a 00 00       	call   801f78 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004c3:	b8 07 00 00 00       	mov    $0x7,%eax
  8004c8:	cd 30                	int    $0x30
  8004ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	79 17                	jns    8004eb <fork+0x3b>
		panic("fork fault %e");
  8004d4:	83 ec 04             	sub    $0x4,%esp
  8004d7:	68 6e 24 80 00       	push   $0x80246e
  8004dc:	68 85 00 00 00       	push   $0x85
  8004e1:	68 4a 24 80 00       	push   $0x80244a
  8004e6:	e8 e8 10 00 00       	call   8015d3 <_panic>
  8004eb:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f1:	75 24                	jne    800517 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004f3:	e8 53 fc ff ff       	call   80014b <sys_getenvid>
  8004f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004fd:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800503:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800508:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80050d:	b8 00 00 00 00       	mov    $0x0,%eax
  800512:	e9 64 01 00 00       	jmp    80067b <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800517:	83 ec 04             	sub    $0x4,%esp
  80051a:	6a 07                	push   $0x7
  80051c:	68 00 f0 bf ee       	push   $0xeebff000
  800521:	ff 75 e4             	pushl  -0x1c(%ebp)
  800524:	e8 60 fc ff ff       	call   800189 <sys_page_alloc>
  800529:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80052c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800531:	89 d8                	mov    %ebx,%eax
  800533:	c1 e8 16             	shr    $0x16,%eax
  800536:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80053d:	a8 01                	test   $0x1,%al
  80053f:	0f 84 fc 00 00 00    	je     800641 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800545:	89 d8                	mov    %ebx,%eax
  800547:	c1 e8 0c             	shr    $0xc,%eax
  80054a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800551:	f6 c2 01             	test   $0x1,%dl
  800554:	0f 84 e7 00 00 00    	je     800641 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80055a:	89 c6                	mov    %eax,%esi
  80055c:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80055f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800566:	f6 c6 04             	test   $0x4,%dh
  800569:	74 39                	je     8005a4 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80056b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800572:	83 ec 0c             	sub    $0xc,%esp
  800575:	25 07 0e 00 00       	and    $0xe07,%eax
  80057a:	50                   	push   %eax
  80057b:	56                   	push   %esi
  80057c:	57                   	push   %edi
  80057d:	56                   	push   %esi
  80057e:	6a 00                	push   $0x0
  800580:	e8 47 fc ff ff       	call   8001cc <sys_page_map>
		if (r < 0) {
  800585:	83 c4 20             	add    $0x20,%esp
  800588:	85 c0                	test   %eax,%eax
  80058a:	0f 89 b1 00 00 00    	jns    800641 <fork+0x191>
		    	panic("sys page map fault %e");
  800590:	83 ec 04             	sub    $0x4,%esp
  800593:	68 7c 24 80 00       	push   $0x80247c
  800598:	6a 55                	push   $0x55
  80059a:	68 4a 24 80 00       	push   $0x80244a
  80059f:	e8 2f 10 00 00       	call   8015d3 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8005a4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ab:	f6 c2 02             	test   $0x2,%dl
  8005ae:	75 0c                	jne    8005bc <fork+0x10c>
  8005b0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b7:	f6 c4 08             	test   $0x8,%ah
  8005ba:	74 5b                	je     800617 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005bc:	83 ec 0c             	sub    $0xc,%esp
  8005bf:	68 05 08 00 00       	push   $0x805
  8005c4:	56                   	push   %esi
  8005c5:	57                   	push   %edi
  8005c6:	56                   	push   %esi
  8005c7:	6a 00                	push   $0x0
  8005c9:	e8 fe fb ff ff       	call   8001cc <sys_page_map>
		if (r < 0) {
  8005ce:	83 c4 20             	add    $0x20,%esp
  8005d1:	85 c0                	test   %eax,%eax
  8005d3:	79 14                	jns    8005e9 <fork+0x139>
		    	panic("sys page map fault %e");
  8005d5:	83 ec 04             	sub    $0x4,%esp
  8005d8:	68 7c 24 80 00       	push   $0x80247c
  8005dd:	6a 5c                	push   $0x5c
  8005df:	68 4a 24 80 00       	push   $0x80244a
  8005e4:	e8 ea 0f 00 00       	call   8015d3 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005e9:	83 ec 0c             	sub    $0xc,%esp
  8005ec:	68 05 08 00 00       	push   $0x805
  8005f1:	56                   	push   %esi
  8005f2:	6a 00                	push   $0x0
  8005f4:	56                   	push   %esi
  8005f5:	6a 00                	push   $0x0
  8005f7:	e8 d0 fb ff ff       	call   8001cc <sys_page_map>
		if (r < 0) {
  8005fc:	83 c4 20             	add    $0x20,%esp
  8005ff:	85 c0                	test   %eax,%eax
  800601:	79 3e                	jns    800641 <fork+0x191>
		    	panic("sys page map fault %e");
  800603:	83 ec 04             	sub    $0x4,%esp
  800606:	68 7c 24 80 00       	push   $0x80247c
  80060b:	6a 60                	push   $0x60
  80060d:	68 4a 24 80 00       	push   $0x80244a
  800612:	e8 bc 0f 00 00       	call   8015d3 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800617:	83 ec 0c             	sub    $0xc,%esp
  80061a:	6a 05                	push   $0x5
  80061c:	56                   	push   %esi
  80061d:	57                   	push   %edi
  80061e:	56                   	push   %esi
  80061f:	6a 00                	push   $0x0
  800621:	e8 a6 fb ff ff       	call   8001cc <sys_page_map>
		if (r < 0) {
  800626:	83 c4 20             	add    $0x20,%esp
  800629:	85 c0                	test   %eax,%eax
  80062b:	79 14                	jns    800641 <fork+0x191>
		    	panic("sys page map fault %e");
  80062d:	83 ec 04             	sub    $0x4,%esp
  800630:	68 7c 24 80 00       	push   $0x80247c
  800635:	6a 65                	push   $0x65
  800637:	68 4a 24 80 00       	push   $0x80244a
  80063c:	e8 92 0f 00 00       	call   8015d3 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800641:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800647:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80064d:	0f 85 de fe ff ff    	jne    800531 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800653:	a1 04 40 80 00       	mov    0x804004,%eax
  800658:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	50                   	push   %eax
  800662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800665:	57                   	push   %edi
  800666:	e8 69 fc ff ff       	call   8002d4 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80066b:	83 c4 08             	add    $0x8,%esp
  80066e:	6a 02                	push   $0x2
  800670:	57                   	push   %edi
  800671:	e8 da fb ff ff       	call   800250 <sys_env_set_status>
	
	return envid;
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80067b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067e:	5b                   	pop    %ebx
  80067f:	5e                   	pop    %esi
  800680:	5f                   	pop    %edi
  800681:	5d                   	pop    %ebp
  800682:	c3                   	ret    

00800683 <sfork>:

envid_t
sfork(void)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800686:	b8 00 00 00 00       	mov    $0x0,%eax
  80068b:	5d                   	pop    %ebp
  80068c:	c3                   	ret    

0080068d <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  800693:	8b 45 08             	mov    0x8(%ebp),%eax
  800696:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80069b:	68 93 00 80 00       	push   $0x800093
  8006a0:	e8 d5 fc ff ff       	call   80037a <sys_thread_create>

	return id;
}
  8006a5:	c9                   	leave  
  8006a6:	c3                   	ret    

008006a7 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8006a7:	55                   	push   %ebp
  8006a8:	89 e5                	mov    %esp,%ebp
  8006aa:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8006ad:	ff 75 08             	pushl  0x8(%ebp)
  8006b0:	e8 e5 fc ff ff       	call   80039a <sys_thread_free>
}
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	c9                   	leave  
  8006b9:	c3                   	ret    

008006ba <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8006c0:	ff 75 08             	pushl  0x8(%ebp)
  8006c3:	e8 f2 fc ff ff       	call   8003ba <sys_thread_join>
}
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    

008006cd <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	56                   	push   %esi
  8006d1:	53                   	push   %ebx
  8006d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8006d8:	83 ec 04             	sub    $0x4,%esp
  8006db:	6a 07                	push   $0x7
  8006dd:	6a 00                	push   $0x0
  8006df:	56                   	push   %esi
  8006e0:	e8 a4 fa ff ff       	call   800189 <sys_page_alloc>
	if (r < 0) {
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	79 15                	jns    800701 <queue_append+0x34>
		panic("%e\n", r);
  8006ec:	50                   	push   %eax
  8006ed:	68 c2 24 80 00       	push   $0x8024c2
  8006f2:	68 d5 00 00 00       	push   $0xd5
  8006f7:	68 4a 24 80 00       	push   $0x80244a
  8006fc:	e8 d2 0e 00 00       	call   8015d3 <_panic>
	}	

	wt->envid = envid;
  800701:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  800707:	83 3b 00             	cmpl   $0x0,(%ebx)
  80070a:	75 13                	jne    80071f <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  80070c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  800713:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80071a:	00 00 00 
  80071d:	eb 1b                	jmp    80073a <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  80071f:	8b 43 04             	mov    0x4(%ebx),%eax
  800722:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  800729:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800730:	00 00 00 
		queue->last = wt;
  800733:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80073a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80073d:	5b                   	pop    %ebx
  80073e:	5e                   	pop    %esi
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 08             	sub    $0x8,%esp
  800747:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  80074a:	8b 02                	mov    (%edx),%eax
  80074c:	85 c0                	test   %eax,%eax
  80074e:	75 17                	jne    800767 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	68 92 24 80 00       	push   $0x802492
  800758:	68 ec 00 00 00       	push   $0xec
  80075d:	68 4a 24 80 00       	push   $0x80244a
  800762:	e8 6c 0e 00 00       	call   8015d3 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  800767:	8b 48 04             	mov    0x4(%eax),%ecx
  80076a:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  80076c:	8b 00                	mov    (%eax),%eax
}
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	53                   	push   %ebx
  800774:	83 ec 04             	sub    $0x4,%esp
  800777:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80077a:	b8 01 00 00 00       	mov    $0x1,%eax
  80077f:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  800782:	85 c0                	test   %eax,%eax
  800784:	74 45                	je     8007cb <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  800786:	e8 c0 f9 ff ff       	call   80014b <sys_getenvid>
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	83 c3 04             	add    $0x4,%ebx
  800791:	53                   	push   %ebx
  800792:	50                   	push   %eax
  800793:	e8 35 ff ff ff       	call   8006cd <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800798:	e8 ae f9 ff ff       	call   80014b <sys_getenvid>
  80079d:	83 c4 08             	add    $0x8,%esp
  8007a0:	6a 04                	push   $0x4
  8007a2:	50                   	push   %eax
  8007a3:	e8 a8 fa ff ff       	call   800250 <sys_env_set_status>

		if (r < 0) {
  8007a8:	83 c4 10             	add    $0x10,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	79 15                	jns    8007c4 <mutex_lock+0x54>
			panic("%e\n", r);
  8007af:	50                   	push   %eax
  8007b0:	68 c2 24 80 00       	push   $0x8024c2
  8007b5:	68 02 01 00 00       	push   $0x102
  8007ba:	68 4a 24 80 00       	push   $0x80244a
  8007bf:	e8 0f 0e 00 00       	call   8015d3 <_panic>
		}
		sys_yield();
  8007c4:	e8 a1 f9 ff ff       	call   80016a <sys_yield>
  8007c9:	eb 08                	jmp    8007d3 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8007cb:	e8 7b f9 ff ff       	call   80014b <sys_getenvid>
  8007d0:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8007d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	83 ec 04             	sub    $0x4,%esp
  8007df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8007e2:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8007e6:	74 36                	je     80081e <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8007e8:	83 ec 0c             	sub    $0xc,%esp
  8007eb:	8d 43 04             	lea    0x4(%ebx),%eax
  8007ee:	50                   	push   %eax
  8007ef:	e8 4d ff ff ff       	call   800741 <queue_pop>
  8007f4:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8007f7:	83 c4 08             	add    $0x8,%esp
  8007fa:	6a 02                	push   $0x2
  8007fc:	50                   	push   %eax
  8007fd:	e8 4e fa ff ff       	call   800250 <sys_env_set_status>
		if (r < 0) {
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	85 c0                	test   %eax,%eax
  800807:	79 1d                	jns    800826 <mutex_unlock+0x4e>
			panic("%e\n", r);
  800809:	50                   	push   %eax
  80080a:	68 c2 24 80 00       	push   $0x8024c2
  80080f:	68 16 01 00 00       	push   $0x116
  800814:	68 4a 24 80 00       	push   $0x80244a
  800819:	e8 b5 0d 00 00       	call   8015d3 <_panic>
  80081e:	b8 00 00 00 00       	mov    $0x0,%eax
  800823:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  800826:	e8 3f f9 ff ff       	call   80016a <sys_yield>
}
  80082b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082e:	c9                   	leave  
  80082f:	c3                   	ret    

00800830 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	53                   	push   %ebx
  800834:	83 ec 04             	sub    $0x4,%esp
  800837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80083a:	e8 0c f9 ff ff       	call   80014b <sys_getenvid>
  80083f:	83 ec 04             	sub    $0x4,%esp
  800842:	6a 07                	push   $0x7
  800844:	53                   	push   %ebx
  800845:	50                   	push   %eax
  800846:	e8 3e f9 ff ff       	call   800189 <sys_page_alloc>
  80084b:	83 c4 10             	add    $0x10,%esp
  80084e:	85 c0                	test   %eax,%eax
  800850:	79 15                	jns    800867 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  800852:	50                   	push   %eax
  800853:	68 ad 24 80 00       	push   $0x8024ad
  800858:	68 23 01 00 00       	push   $0x123
  80085d:	68 4a 24 80 00       	push   $0x80244a
  800862:	e8 6c 0d 00 00       	call   8015d3 <_panic>
	}	
	mtx->locked = 0;
  800867:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  80086d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  800874:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  80087b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  800882:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	56                   	push   %esi
  80088b:	53                   	push   %ebx
  80088c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  80088f:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  800892:	eb 20                	jmp    8008b4 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  800894:	83 ec 0c             	sub    $0xc,%esp
  800897:	56                   	push   %esi
  800898:	e8 a4 fe ff ff       	call   800741 <queue_pop>
  80089d:	83 c4 08             	add    $0x8,%esp
  8008a0:	6a 02                	push   $0x2
  8008a2:	50                   	push   %eax
  8008a3:	e8 a8 f9 ff ff       	call   800250 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8008a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8008ab:	8b 40 04             	mov    0x4(%eax),%eax
  8008ae:	89 43 04             	mov    %eax,0x4(%ebx)
  8008b1:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8008b4:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8008b8:	75 da                	jne    800894 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008ba:	83 ec 04             	sub    $0x4,%esp
  8008bd:	68 00 10 00 00       	push   $0x1000
  8008c2:	6a 00                	push   $0x0
  8008c4:	53                   	push   %ebx
  8008c5:	e8 ac 14 00 00       	call   801d76 <memset>
	mtx = NULL;
}
  8008ca:	83 c4 10             	add    $0x10,%esp
  8008cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	05 00 00 00 30       	add    $0x30000000,%eax
  8008df:	c1 e8 0c             	shr    $0xc,%eax
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	05 00 00 00 30       	add    $0x30000000,%eax
  8008ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8008f4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800901:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800906:	89 c2                	mov    %eax,%edx
  800908:	c1 ea 16             	shr    $0x16,%edx
  80090b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800912:	f6 c2 01             	test   $0x1,%dl
  800915:	74 11                	je     800928 <fd_alloc+0x2d>
  800917:	89 c2                	mov    %eax,%edx
  800919:	c1 ea 0c             	shr    $0xc,%edx
  80091c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800923:	f6 c2 01             	test   $0x1,%dl
  800926:	75 09                	jne    800931 <fd_alloc+0x36>
			*fd_store = fd;
  800928:	89 01                	mov    %eax,(%ecx)
			return 0;
  80092a:	b8 00 00 00 00       	mov    $0x0,%eax
  80092f:	eb 17                	jmp    800948 <fd_alloc+0x4d>
  800931:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800936:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80093b:	75 c9                	jne    800906 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80093d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800943:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800950:	83 f8 1f             	cmp    $0x1f,%eax
  800953:	77 36                	ja     80098b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800955:	c1 e0 0c             	shl    $0xc,%eax
  800958:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80095d:	89 c2                	mov    %eax,%edx
  80095f:	c1 ea 16             	shr    $0x16,%edx
  800962:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800969:	f6 c2 01             	test   $0x1,%dl
  80096c:	74 24                	je     800992 <fd_lookup+0x48>
  80096e:	89 c2                	mov    %eax,%edx
  800970:	c1 ea 0c             	shr    $0xc,%edx
  800973:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80097a:	f6 c2 01             	test   $0x1,%dl
  80097d:	74 1a                	je     800999 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80097f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800982:	89 02                	mov    %eax,(%edx)
	return 0;
  800984:	b8 00 00 00 00       	mov    $0x0,%eax
  800989:	eb 13                	jmp    80099e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80098b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800990:	eb 0c                	jmp    80099e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800992:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800997:	eb 05                	jmp    80099e <fd_lookup+0x54>
  800999:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	83 ec 08             	sub    $0x8,%esp
  8009a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a9:	ba 44 25 80 00       	mov    $0x802544,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8009ae:	eb 13                	jmp    8009c3 <dev_lookup+0x23>
  8009b0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009b3:	39 08                	cmp    %ecx,(%eax)
  8009b5:	75 0c                	jne    8009c3 <dev_lookup+0x23>
			*dev = devtab[i];
  8009b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ba:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c1:	eb 31                	jmp    8009f4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009c3:	8b 02                	mov    (%edx),%eax
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	75 e7                	jne    8009b0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8009ce:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8009d4:	83 ec 04             	sub    $0x4,%esp
  8009d7:	51                   	push   %ecx
  8009d8:	50                   	push   %eax
  8009d9:	68 c8 24 80 00       	push   $0x8024c8
  8009de:	e8 c9 0c 00 00       	call   8016ac <cprintf>
	*dev = 0;
  8009e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8009ec:	83 c4 10             	add    $0x10,%esp
  8009ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	83 ec 10             	sub    $0x10,%esp
  8009fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800a01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a07:	50                   	push   %eax
  800a08:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a0e:	c1 e8 0c             	shr    $0xc,%eax
  800a11:	50                   	push   %eax
  800a12:	e8 33 ff ff ff       	call   80094a <fd_lookup>
  800a17:	83 c4 08             	add    $0x8,%esp
  800a1a:	85 c0                	test   %eax,%eax
  800a1c:	78 05                	js     800a23 <fd_close+0x2d>
	    || fd != fd2)
  800a1e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a21:	74 0c                	je     800a2f <fd_close+0x39>
		return (must_exist ? r : 0);
  800a23:	84 db                	test   %bl,%bl
  800a25:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2a:	0f 44 c2             	cmove  %edx,%eax
  800a2d:	eb 41                	jmp    800a70 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a2f:	83 ec 08             	sub    $0x8,%esp
  800a32:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a35:	50                   	push   %eax
  800a36:	ff 36                	pushl  (%esi)
  800a38:	e8 63 ff ff ff       	call   8009a0 <dev_lookup>
  800a3d:	89 c3                	mov    %eax,%ebx
  800a3f:	83 c4 10             	add    $0x10,%esp
  800a42:	85 c0                	test   %eax,%eax
  800a44:	78 1a                	js     800a60 <fd_close+0x6a>
		if (dev->dev_close)
  800a46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a49:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a4c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a51:	85 c0                	test   %eax,%eax
  800a53:	74 0b                	je     800a60 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a55:	83 ec 0c             	sub    $0xc,%esp
  800a58:	56                   	push   %esi
  800a59:	ff d0                	call   *%eax
  800a5b:	89 c3                	mov    %eax,%ebx
  800a5d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a60:	83 ec 08             	sub    $0x8,%esp
  800a63:	56                   	push   %esi
  800a64:	6a 00                	push   $0x0
  800a66:	e8 a3 f7 ff ff       	call   80020e <sys_page_unmap>
	return r;
  800a6b:	83 c4 10             	add    $0x10,%esp
  800a6e:	89 d8                	mov    %ebx,%eax
}
  800a70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a73:	5b                   	pop    %ebx
  800a74:	5e                   	pop    %esi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a80:	50                   	push   %eax
  800a81:	ff 75 08             	pushl  0x8(%ebp)
  800a84:	e8 c1 fe ff ff       	call   80094a <fd_lookup>
  800a89:	83 c4 08             	add    $0x8,%esp
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	78 10                	js     800aa0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800a90:	83 ec 08             	sub    $0x8,%esp
  800a93:	6a 01                	push   $0x1
  800a95:	ff 75 f4             	pushl  -0xc(%ebp)
  800a98:	e8 59 ff ff ff       	call   8009f6 <fd_close>
  800a9d:	83 c4 10             	add    $0x10,%esp
}
  800aa0:	c9                   	leave  
  800aa1:	c3                   	ret    

00800aa2 <close_all>:

void
close_all(void)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	53                   	push   %ebx
  800aa6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800aa9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800aae:	83 ec 0c             	sub    $0xc,%esp
  800ab1:	53                   	push   %ebx
  800ab2:	e8 c0 ff ff ff       	call   800a77 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ab7:	83 c3 01             	add    $0x1,%ebx
  800aba:	83 c4 10             	add    $0x10,%esp
  800abd:	83 fb 20             	cmp    $0x20,%ebx
  800ac0:	75 ec                	jne    800aae <close_all+0xc>
		close(i);
}
  800ac2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac5:	c9                   	leave  
  800ac6:	c3                   	ret    

00800ac7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	83 ec 2c             	sub    $0x2c,%esp
  800ad0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ad3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ad6:	50                   	push   %eax
  800ad7:	ff 75 08             	pushl  0x8(%ebp)
  800ada:	e8 6b fe ff ff       	call   80094a <fd_lookup>
  800adf:	83 c4 08             	add    $0x8,%esp
  800ae2:	85 c0                	test   %eax,%eax
  800ae4:	0f 88 c1 00 00 00    	js     800bab <dup+0xe4>
		return r;
	close(newfdnum);
  800aea:	83 ec 0c             	sub    $0xc,%esp
  800aed:	56                   	push   %esi
  800aee:	e8 84 ff ff ff       	call   800a77 <close>

	newfd = INDEX2FD(newfdnum);
  800af3:	89 f3                	mov    %esi,%ebx
  800af5:	c1 e3 0c             	shl    $0xc,%ebx
  800af8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800afe:	83 c4 04             	add    $0x4,%esp
  800b01:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b04:	e8 db fd ff ff       	call   8008e4 <fd2data>
  800b09:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b0b:	89 1c 24             	mov    %ebx,(%esp)
  800b0e:	e8 d1 fd ff ff       	call   8008e4 <fd2data>
  800b13:	83 c4 10             	add    $0x10,%esp
  800b16:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b19:	89 f8                	mov    %edi,%eax
  800b1b:	c1 e8 16             	shr    $0x16,%eax
  800b1e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b25:	a8 01                	test   $0x1,%al
  800b27:	74 37                	je     800b60 <dup+0x99>
  800b29:	89 f8                	mov    %edi,%eax
  800b2b:	c1 e8 0c             	shr    $0xc,%eax
  800b2e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b35:	f6 c2 01             	test   $0x1,%dl
  800b38:	74 26                	je     800b60 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b3a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b41:	83 ec 0c             	sub    $0xc,%esp
  800b44:	25 07 0e 00 00       	and    $0xe07,%eax
  800b49:	50                   	push   %eax
  800b4a:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b4d:	6a 00                	push   $0x0
  800b4f:	57                   	push   %edi
  800b50:	6a 00                	push   $0x0
  800b52:	e8 75 f6 ff ff       	call   8001cc <sys_page_map>
  800b57:	89 c7                	mov    %eax,%edi
  800b59:	83 c4 20             	add    $0x20,%esp
  800b5c:	85 c0                	test   %eax,%eax
  800b5e:	78 2e                	js     800b8e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b60:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b63:	89 d0                	mov    %edx,%eax
  800b65:	c1 e8 0c             	shr    $0xc,%eax
  800b68:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b6f:	83 ec 0c             	sub    $0xc,%esp
  800b72:	25 07 0e 00 00       	and    $0xe07,%eax
  800b77:	50                   	push   %eax
  800b78:	53                   	push   %ebx
  800b79:	6a 00                	push   $0x0
  800b7b:	52                   	push   %edx
  800b7c:	6a 00                	push   $0x0
  800b7e:	e8 49 f6 ff ff       	call   8001cc <sys_page_map>
  800b83:	89 c7                	mov    %eax,%edi
  800b85:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800b88:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b8a:	85 ff                	test   %edi,%edi
  800b8c:	79 1d                	jns    800bab <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b8e:	83 ec 08             	sub    $0x8,%esp
  800b91:	53                   	push   %ebx
  800b92:	6a 00                	push   $0x0
  800b94:	e8 75 f6 ff ff       	call   80020e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b99:	83 c4 08             	add    $0x8,%esp
  800b9c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b9f:	6a 00                	push   $0x0
  800ba1:	e8 68 f6 ff ff       	call   80020e <sys_page_unmap>
	return r;
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	89 f8                	mov    %edi,%eax
}
  800bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 14             	sub    $0x14,%esp
  800bba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bbd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bc0:	50                   	push   %eax
  800bc1:	53                   	push   %ebx
  800bc2:	e8 83 fd ff ff       	call   80094a <fd_lookup>
  800bc7:	83 c4 08             	add    $0x8,%esp
  800bca:	89 c2                	mov    %eax,%edx
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	78 70                	js     800c40 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bd0:	83 ec 08             	sub    $0x8,%esp
  800bd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bd6:	50                   	push   %eax
  800bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bda:	ff 30                	pushl  (%eax)
  800bdc:	e8 bf fd ff ff       	call   8009a0 <dev_lookup>
  800be1:	83 c4 10             	add    $0x10,%esp
  800be4:	85 c0                	test   %eax,%eax
  800be6:	78 4f                	js     800c37 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800be8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800beb:	8b 42 08             	mov    0x8(%edx),%eax
  800bee:	83 e0 03             	and    $0x3,%eax
  800bf1:	83 f8 01             	cmp    $0x1,%eax
  800bf4:	75 24                	jne    800c1a <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800bf6:	a1 04 40 80 00       	mov    0x804004,%eax
  800bfb:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800c01:	83 ec 04             	sub    $0x4,%esp
  800c04:	53                   	push   %ebx
  800c05:	50                   	push   %eax
  800c06:	68 09 25 80 00       	push   $0x802509
  800c0b:	e8 9c 0a 00 00       	call   8016ac <cprintf>
		return -E_INVAL;
  800c10:	83 c4 10             	add    $0x10,%esp
  800c13:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c18:	eb 26                	jmp    800c40 <read+0x8d>
	}
	if (!dev->dev_read)
  800c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1d:	8b 40 08             	mov    0x8(%eax),%eax
  800c20:	85 c0                	test   %eax,%eax
  800c22:	74 17                	je     800c3b <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c24:	83 ec 04             	sub    $0x4,%esp
  800c27:	ff 75 10             	pushl  0x10(%ebp)
  800c2a:	ff 75 0c             	pushl  0xc(%ebp)
  800c2d:	52                   	push   %edx
  800c2e:	ff d0                	call   *%eax
  800c30:	89 c2                	mov    %eax,%edx
  800c32:	83 c4 10             	add    $0x10,%esp
  800c35:	eb 09                	jmp    800c40 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c37:	89 c2                	mov    %eax,%edx
  800c39:	eb 05                	jmp    800c40 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c3b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c40:	89 d0                	mov    %edx,%eax
  800c42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c45:	c9                   	leave  
  800c46:	c3                   	ret    

00800c47 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
  800c50:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c53:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5b:	eb 21                	jmp    800c7e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c5d:	83 ec 04             	sub    $0x4,%esp
  800c60:	89 f0                	mov    %esi,%eax
  800c62:	29 d8                	sub    %ebx,%eax
  800c64:	50                   	push   %eax
  800c65:	89 d8                	mov    %ebx,%eax
  800c67:	03 45 0c             	add    0xc(%ebp),%eax
  800c6a:	50                   	push   %eax
  800c6b:	57                   	push   %edi
  800c6c:	e8 42 ff ff ff       	call   800bb3 <read>
		if (m < 0)
  800c71:	83 c4 10             	add    $0x10,%esp
  800c74:	85 c0                	test   %eax,%eax
  800c76:	78 10                	js     800c88 <readn+0x41>
			return m;
		if (m == 0)
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	74 0a                	je     800c86 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c7c:	01 c3                	add    %eax,%ebx
  800c7e:	39 f3                	cmp    %esi,%ebx
  800c80:	72 db                	jb     800c5d <readn+0x16>
  800c82:	89 d8                	mov    %ebx,%eax
  800c84:	eb 02                	jmp    800c88 <readn+0x41>
  800c86:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	53                   	push   %ebx
  800c94:	83 ec 14             	sub    $0x14,%esp
  800c97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c9d:	50                   	push   %eax
  800c9e:	53                   	push   %ebx
  800c9f:	e8 a6 fc ff ff       	call   80094a <fd_lookup>
  800ca4:	83 c4 08             	add    $0x8,%esp
  800ca7:	89 c2                	mov    %eax,%edx
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	78 6b                	js     800d18 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cad:	83 ec 08             	sub    $0x8,%esp
  800cb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cb3:	50                   	push   %eax
  800cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cb7:	ff 30                	pushl  (%eax)
  800cb9:	e8 e2 fc ff ff       	call   8009a0 <dev_lookup>
  800cbe:	83 c4 10             	add    $0x10,%esp
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	78 4a                	js     800d0f <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cc8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ccc:	75 24                	jne    800cf2 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800cce:	a1 04 40 80 00       	mov    0x804004,%eax
  800cd3:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800cd9:	83 ec 04             	sub    $0x4,%esp
  800cdc:	53                   	push   %ebx
  800cdd:	50                   	push   %eax
  800cde:	68 25 25 80 00       	push   $0x802525
  800ce3:	e8 c4 09 00 00       	call   8016ac <cprintf>
		return -E_INVAL;
  800ce8:	83 c4 10             	add    $0x10,%esp
  800ceb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800cf0:	eb 26                	jmp    800d18 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800cf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cf5:	8b 52 0c             	mov    0xc(%edx),%edx
  800cf8:	85 d2                	test   %edx,%edx
  800cfa:	74 17                	je     800d13 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800cfc:	83 ec 04             	sub    $0x4,%esp
  800cff:	ff 75 10             	pushl  0x10(%ebp)
  800d02:	ff 75 0c             	pushl  0xc(%ebp)
  800d05:	50                   	push   %eax
  800d06:	ff d2                	call   *%edx
  800d08:	89 c2                	mov    %eax,%edx
  800d0a:	83 c4 10             	add    $0x10,%esp
  800d0d:	eb 09                	jmp    800d18 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d0f:	89 c2                	mov    %eax,%edx
  800d11:	eb 05                	jmp    800d18 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d13:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d18:	89 d0                	mov    %edx,%eax
  800d1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d1d:	c9                   	leave  
  800d1e:	c3                   	ret    

00800d1f <seek>:

int
seek(int fdnum, off_t offset)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d25:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d28:	50                   	push   %eax
  800d29:	ff 75 08             	pushl  0x8(%ebp)
  800d2c:	e8 19 fc ff ff       	call   80094a <fd_lookup>
  800d31:	83 c4 08             	add    $0x8,%esp
  800d34:	85 c0                	test   %eax,%eax
  800d36:	78 0e                	js     800d46 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d38:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d3e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d46:	c9                   	leave  
  800d47:	c3                   	ret    

00800d48 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	53                   	push   %ebx
  800d4c:	83 ec 14             	sub    $0x14,%esp
  800d4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d52:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d55:	50                   	push   %eax
  800d56:	53                   	push   %ebx
  800d57:	e8 ee fb ff ff       	call   80094a <fd_lookup>
  800d5c:	83 c4 08             	add    $0x8,%esp
  800d5f:	89 c2                	mov    %eax,%edx
  800d61:	85 c0                	test   %eax,%eax
  800d63:	78 68                	js     800dcd <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d65:	83 ec 08             	sub    $0x8,%esp
  800d68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d6b:	50                   	push   %eax
  800d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d6f:	ff 30                	pushl  (%eax)
  800d71:	e8 2a fc ff ff       	call   8009a0 <dev_lookup>
  800d76:	83 c4 10             	add    $0x10,%esp
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	78 47                	js     800dc4 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d80:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d84:	75 24                	jne    800daa <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800d86:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800d8b:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800d91:	83 ec 04             	sub    $0x4,%esp
  800d94:	53                   	push   %ebx
  800d95:	50                   	push   %eax
  800d96:	68 e8 24 80 00       	push   $0x8024e8
  800d9b:	e8 0c 09 00 00       	call   8016ac <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800da0:	83 c4 10             	add    $0x10,%esp
  800da3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800da8:	eb 23                	jmp    800dcd <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800daa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dad:	8b 52 18             	mov    0x18(%edx),%edx
  800db0:	85 d2                	test   %edx,%edx
  800db2:	74 14                	je     800dc8 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800db4:	83 ec 08             	sub    $0x8,%esp
  800db7:	ff 75 0c             	pushl  0xc(%ebp)
  800dba:	50                   	push   %eax
  800dbb:	ff d2                	call   *%edx
  800dbd:	89 c2                	mov    %eax,%edx
  800dbf:	83 c4 10             	add    $0x10,%esp
  800dc2:	eb 09                	jmp    800dcd <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800dc4:	89 c2                	mov    %eax,%edx
  800dc6:	eb 05                	jmp    800dcd <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800dc8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800dcd:	89 d0                	mov    %edx,%eax
  800dcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd2:	c9                   	leave  
  800dd3:	c3                   	ret    

00800dd4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 14             	sub    $0x14,%esp
  800ddb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dde:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800de1:	50                   	push   %eax
  800de2:	ff 75 08             	pushl  0x8(%ebp)
  800de5:	e8 60 fb ff ff       	call   80094a <fd_lookup>
  800dea:	83 c4 08             	add    $0x8,%esp
  800ded:	89 c2                	mov    %eax,%edx
  800def:	85 c0                	test   %eax,%eax
  800df1:	78 58                	js     800e4b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800df3:	83 ec 08             	sub    $0x8,%esp
  800df6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800df9:	50                   	push   %eax
  800dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dfd:	ff 30                	pushl  (%eax)
  800dff:	e8 9c fb ff ff       	call   8009a0 <dev_lookup>
  800e04:	83 c4 10             	add    $0x10,%esp
  800e07:	85 c0                	test   %eax,%eax
  800e09:	78 37                	js     800e42 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e12:	74 32                	je     800e46 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e14:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e17:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e1e:	00 00 00 
	stat->st_isdir = 0;
  800e21:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e28:	00 00 00 
	stat->st_dev = dev;
  800e2b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e31:	83 ec 08             	sub    $0x8,%esp
  800e34:	53                   	push   %ebx
  800e35:	ff 75 f0             	pushl  -0x10(%ebp)
  800e38:	ff 50 14             	call   *0x14(%eax)
  800e3b:	89 c2                	mov    %eax,%edx
  800e3d:	83 c4 10             	add    $0x10,%esp
  800e40:	eb 09                	jmp    800e4b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e42:	89 c2                	mov    %eax,%edx
  800e44:	eb 05                	jmp    800e4b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e46:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e4b:	89 d0                	mov    %edx,%eax
  800e4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e50:	c9                   	leave  
  800e51:	c3                   	ret    

00800e52 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	56                   	push   %esi
  800e56:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e57:	83 ec 08             	sub    $0x8,%esp
  800e5a:	6a 00                	push   $0x0
  800e5c:	ff 75 08             	pushl  0x8(%ebp)
  800e5f:	e8 e3 01 00 00       	call   801047 <open>
  800e64:	89 c3                	mov    %eax,%ebx
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	78 1b                	js     800e88 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	ff 75 0c             	pushl  0xc(%ebp)
  800e73:	50                   	push   %eax
  800e74:	e8 5b ff ff ff       	call   800dd4 <fstat>
  800e79:	89 c6                	mov    %eax,%esi
	close(fd);
  800e7b:	89 1c 24             	mov    %ebx,(%esp)
  800e7e:	e8 f4 fb ff ff       	call   800a77 <close>
	return r;
  800e83:	83 c4 10             	add    $0x10,%esp
  800e86:	89 f0                	mov    %esi,%eax
}
  800e88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	89 c6                	mov    %eax,%esi
  800e96:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800e98:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e9f:	75 12                	jne    800eb3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ea1:	83 ec 0c             	sub    $0xc,%esp
  800ea4:	6a 01                	push   $0x1
  800ea6:	e8 39 12 00 00       	call   8020e4 <ipc_find_env>
  800eab:	a3 00 40 80 00       	mov    %eax,0x804000
  800eb0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800eb3:	6a 07                	push   $0x7
  800eb5:	68 00 50 80 00       	push   $0x805000
  800eba:	56                   	push   %esi
  800ebb:	ff 35 00 40 80 00    	pushl  0x804000
  800ec1:	e8 bc 11 00 00       	call   802082 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ec6:	83 c4 0c             	add    $0xc,%esp
  800ec9:	6a 00                	push   $0x0
  800ecb:	53                   	push   %ebx
  800ecc:	6a 00                	push   $0x0
  800ece:	e8 34 11 00 00       	call   802007 <ipc_recv>
}
  800ed3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee3:	8b 40 0c             	mov    0xc(%eax),%eax
  800ee6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800eeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eee:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ef3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef8:	b8 02 00 00 00       	mov    $0x2,%eax
  800efd:	e8 8d ff ff ff       	call   800e8f <fsipc>
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0d:	8b 40 0c             	mov    0xc(%eax),%eax
  800f10:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f15:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1a:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1f:	e8 6b ff ff ff       	call   800e8f <fsipc>
}
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    

00800f26 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	53                   	push   %ebx
  800f2a:	83 ec 04             	sub    $0x4,%esp
  800f2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
  800f33:	8b 40 0c             	mov    0xc(%eax),%eax
  800f36:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f40:	b8 05 00 00 00       	mov    $0x5,%eax
  800f45:	e8 45 ff ff ff       	call   800e8f <fsipc>
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	78 2c                	js     800f7a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f4e:	83 ec 08             	sub    $0x8,%esp
  800f51:	68 00 50 80 00       	push   $0x805000
  800f56:	53                   	push   %ebx
  800f57:	e8 d5 0c 00 00       	call   801c31 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f5c:	a1 80 50 80 00       	mov    0x805080,%eax
  800f61:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f67:	a1 84 50 80 00       	mov    0x805084,%eax
  800f6c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    

00800f7f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 0c             	sub    $0xc,%esp
  800f85:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f88:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8b:	8b 52 0c             	mov    0xc(%edx),%edx
  800f8e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800f94:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f99:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800f9e:	0f 47 c2             	cmova  %edx,%eax
  800fa1:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800fa6:	50                   	push   %eax
  800fa7:	ff 75 0c             	pushl  0xc(%ebp)
  800faa:	68 08 50 80 00       	push   $0x805008
  800faf:	e8 0f 0e 00 00       	call   801dc3 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb9:	b8 04 00 00 00       	mov    $0x4,%eax
  800fbe:	e8 cc fe ff ff       	call   800e8f <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800fc3:	c9                   	leave  
  800fc4:	c3                   	ret    

00800fc5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	56                   	push   %esi
  800fc9:	53                   	push   %ebx
  800fca:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd0:	8b 40 0c             	mov    0xc(%eax),%eax
  800fd3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800fd8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800fde:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe3:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe8:	e8 a2 fe ff ff       	call   800e8f <fsipc>
  800fed:	89 c3                	mov    %eax,%ebx
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	78 4b                	js     80103e <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ff3:	39 c6                	cmp    %eax,%esi
  800ff5:	73 16                	jae    80100d <devfile_read+0x48>
  800ff7:	68 54 25 80 00       	push   $0x802554
  800ffc:	68 5b 25 80 00       	push   $0x80255b
  801001:	6a 7c                	push   $0x7c
  801003:	68 70 25 80 00       	push   $0x802570
  801008:	e8 c6 05 00 00       	call   8015d3 <_panic>
	assert(r <= PGSIZE);
  80100d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801012:	7e 16                	jle    80102a <devfile_read+0x65>
  801014:	68 7b 25 80 00       	push   $0x80257b
  801019:	68 5b 25 80 00       	push   $0x80255b
  80101e:	6a 7d                	push   $0x7d
  801020:	68 70 25 80 00       	push   $0x802570
  801025:	e8 a9 05 00 00       	call   8015d3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80102a:	83 ec 04             	sub    $0x4,%esp
  80102d:	50                   	push   %eax
  80102e:	68 00 50 80 00       	push   $0x805000
  801033:	ff 75 0c             	pushl  0xc(%ebp)
  801036:	e8 88 0d 00 00       	call   801dc3 <memmove>
	return r;
  80103b:	83 c4 10             	add    $0x10,%esp
}
  80103e:	89 d8                	mov    %ebx,%eax
  801040:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801043:	5b                   	pop    %ebx
  801044:	5e                   	pop    %esi
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	53                   	push   %ebx
  80104b:	83 ec 20             	sub    $0x20,%esp
  80104e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801051:	53                   	push   %ebx
  801052:	e8 a1 0b 00 00       	call   801bf8 <strlen>
  801057:	83 c4 10             	add    $0x10,%esp
  80105a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80105f:	7f 67                	jg     8010c8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801067:	50                   	push   %eax
  801068:	e8 8e f8 ff ff       	call   8008fb <fd_alloc>
  80106d:	83 c4 10             	add    $0x10,%esp
		return r;
  801070:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801072:	85 c0                	test   %eax,%eax
  801074:	78 57                	js     8010cd <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801076:	83 ec 08             	sub    $0x8,%esp
  801079:	53                   	push   %ebx
  80107a:	68 00 50 80 00       	push   $0x805000
  80107f:	e8 ad 0b 00 00       	call   801c31 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801084:	8b 45 0c             	mov    0xc(%ebp),%eax
  801087:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80108c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80108f:	b8 01 00 00 00       	mov    $0x1,%eax
  801094:	e8 f6 fd ff ff       	call   800e8f <fsipc>
  801099:	89 c3                	mov    %eax,%ebx
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	79 14                	jns    8010b6 <open+0x6f>
		fd_close(fd, 0);
  8010a2:	83 ec 08             	sub    $0x8,%esp
  8010a5:	6a 00                	push   $0x0
  8010a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8010aa:	e8 47 f9 ff ff       	call   8009f6 <fd_close>
		return r;
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	89 da                	mov    %ebx,%edx
  8010b4:	eb 17                	jmp    8010cd <open+0x86>
	}

	return fd2num(fd);
  8010b6:	83 ec 0c             	sub    $0xc,%esp
  8010b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8010bc:	e8 13 f8 ff ff       	call   8008d4 <fd2num>
  8010c1:	89 c2                	mov    %eax,%edx
  8010c3:	83 c4 10             	add    $0x10,%esp
  8010c6:	eb 05                	jmp    8010cd <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010c8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010cd:	89 d0                	mov    %edx,%eax
  8010cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d2:	c9                   	leave  
  8010d3:	c3                   	ret    

008010d4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010da:	ba 00 00 00 00       	mov    $0x0,%edx
  8010df:	b8 08 00 00 00       	mov    $0x8,%eax
  8010e4:	e8 a6 fd ff ff       	call   800e8f <fsipc>
}
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	56                   	push   %esi
  8010ef:	53                   	push   %ebx
  8010f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	ff 75 08             	pushl  0x8(%ebp)
  8010f9:	e8 e6 f7 ff ff       	call   8008e4 <fd2data>
  8010fe:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801100:	83 c4 08             	add    $0x8,%esp
  801103:	68 87 25 80 00       	push   $0x802587
  801108:	53                   	push   %ebx
  801109:	e8 23 0b 00 00       	call   801c31 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80110e:	8b 46 04             	mov    0x4(%esi),%eax
  801111:	2b 06                	sub    (%esi),%eax
  801113:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801119:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801120:	00 00 00 
	stat->st_dev = &devpipe;
  801123:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80112a:	30 80 00 
	return 0;
}
  80112d:	b8 00 00 00 00       	mov    $0x0,%eax
  801132:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5d                   	pop    %ebp
  801138:	c3                   	ret    

00801139 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	53                   	push   %ebx
  80113d:	83 ec 0c             	sub    $0xc,%esp
  801140:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801143:	53                   	push   %ebx
  801144:	6a 00                	push   $0x0
  801146:	e8 c3 f0 ff ff       	call   80020e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80114b:	89 1c 24             	mov    %ebx,(%esp)
  80114e:	e8 91 f7 ff ff       	call   8008e4 <fd2data>
  801153:	83 c4 08             	add    $0x8,%esp
  801156:	50                   	push   %eax
  801157:	6a 00                	push   $0x0
  801159:	e8 b0 f0 ff ff       	call   80020e <sys_page_unmap>
}
  80115e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801161:	c9                   	leave  
  801162:	c3                   	ret    

00801163 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	57                   	push   %edi
  801167:	56                   	push   %esi
  801168:	53                   	push   %ebx
  801169:	83 ec 1c             	sub    $0x1c,%esp
  80116c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80116f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801171:	a1 04 40 80 00       	mov    0x804004,%eax
  801176:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80117c:	83 ec 0c             	sub    $0xc,%esp
  80117f:	ff 75 e0             	pushl  -0x20(%ebp)
  801182:	e8 a2 0f 00 00       	call   802129 <pageref>
  801187:	89 c3                	mov    %eax,%ebx
  801189:	89 3c 24             	mov    %edi,(%esp)
  80118c:	e8 98 0f 00 00       	call   802129 <pageref>
  801191:	83 c4 10             	add    $0x10,%esp
  801194:	39 c3                	cmp    %eax,%ebx
  801196:	0f 94 c1             	sete   %cl
  801199:	0f b6 c9             	movzbl %cl,%ecx
  80119c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80119f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8011a5:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  8011ab:	39 ce                	cmp    %ecx,%esi
  8011ad:	74 1e                	je     8011cd <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8011af:	39 c3                	cmp    %eax,%ebx
  8011b1:	75 be                	jne    801171 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011b3:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011bc:	50                   	push   %eax
  8011bd:	56                   	push   %esi
  8011be:	68 8e 25 80 00       	push   $0x80258e
  8011c3:	e8 e4 04 00 00       	call   8016ac <cprintf>
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	eb a4                	jmp    801171 <_pipeisclosed+0xe>
	}
}
  8011cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	57                   	push   %edi
  8011dc:	56                   	push   %esi
  8011dd:	53                   	push   %ebx
  8011de:	83 ec 28             	sub    $0x28,%esp
  8011e1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011e4:	56                   	push   %esi
  8011e5:	e8 fa f6 ff ff       	call   8008e4 <fd2data>
  8011ea:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8011f4:	eb 4b                	jmp    801241 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011f6:	89 da                	mov    %ebx,%edx
  8011f8:	89 f0                	mov    %esi,%eax
  8011fa:	e8 64 ff ff ff       	call   801163 <_pipeisclosed>
  8011ff:	85 c0                	test   %eax,%eax
  801201:	75 48                	jne    80124b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801203:	e8 62 ef ff ff       	call   80016a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801208:	8b 43 04             	mov    0x4(%ebx),%eax
  80120b:	8b 0b                	mov    (%ebx),%ecx
  80120d:	8d 51 20             	lea    0x20(%ecx),%edx
  801210:	39 d0                	cmp    %edx,%eax
  801212:	73 e2                	jae    8011f6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801214:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801217:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80121b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80121e:	89 c2                	mov    %eax,%edx
  801220:	c1 fa 1f             	sar    $0x1f,%edx
  801223:	89 d1                	mov    %edx,%ecx
  801225:	c1 e9 1b             	shr    $0x1b,%ecx
  801228:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80122b:	83 e2 1f             	and    $0x1f,%edx
  80122e:	29 ca                	sub    %ecx,%edx
  801230:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801234:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801238:	83 c0 01             	add    $0x1,%eax
  80123b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80123e:	83 c7 01             	add    $0x1,%edi
  801241:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801244:	75 c2                	jne    801208 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801246:	8b 45 10             	mov    0x10(%ebp),%eax
  801249:	eb 05                	jmp    801250 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80124b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801253:	5b                   	pop    %ebx
  801254:	5e                   	pop    %esi
  801255:	5f                   	pop    %edi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	57                   	push   %edi
  80125c:	56                   	push   %esi
  80125d:	53                   	push   %ebx
  80125e:	83 ec 18             	sub    $0x18,%esp
  801261:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801264:	57                   	push   %edi
  801265:	e8 7a f6 ff ff       	call   8008e4 <fd2data>
  80126a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801274:	eb 3d                	jmp    8012b3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801276:	85 db                	test   %ebx,%ebx
  801278:	74 04                	je     80127e <devpipe_read+0x26>
				return i;
  80127a:	89 d8                	mov    %ebx,%eax
  80127c:	eb 44                	jmp    8012c2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80127e:	89 f2                	mov    %esi,%edx
  801280:	89 f8                	mov    %edi,%eax
  801282:	e8 dc fe ff ff       	call   801163 <_pipeisclosed>
  801287:	85 c0                	test   %eax,%eax
  801289:	75 32                	jne    8012bd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80128b:	e8 da ee ff ff       	call   80016a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801290:	8b 06                	mov    (%esi),%eax
  801292:	3b 46 04             	cmp    0x4(%esi),%eax
  801295:	74 df                	je     801276 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801297:	99                   	cltd   
  801298:	c1 ea 1b             	shr    $0x1b,%edx
  80129b:	01 d0                	add    %edx,%eax
  80129d:	83 e0 1f             	and    $0x1f,%eax
  8012a0:	29 d0                	sub    %edx,%eax
  8012a2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8012a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012aa:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8012ad:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012b0:	83 c3 01             	add    $0x1,%ebx
  8012b3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012b6:	75 d8                	jne    801290 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8012bb:	eb 05                	jmp    8012c2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012bd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c5:	5b                   	pop    %ebx
  8012c6:	5e                   	pop    %esi
  8012c7:	5f                   	pop    %edi
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    

008012ca <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d5:	50                   	push   %eax
  8012d6:	e8 20 f6 ff ff       	call   8008fb <fd_alloc>
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	0f 88 2c 01 00 00    	js     801414 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012e8:	83 ec 04             	sub    $0x4,%esp
  8012eb:	68 07 04 00 00       	push   $0x407
  8012f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f3:	6a 00                	push   $0x0
  8012f5:	e8 8f ee ff ff       	call   800189 <sys_page_alloc>
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	89 c2                	mov    %eax,%edx
  8012ff:	85 c0                	test   %eax,%eax
  801301:	0f 88 0d 01 00 00    	js     801414 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801307:	83 ec 0c             	sub    $0xc,%esp
  80130a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130d:	50                   	push   %eax
  80130e:	e8 e8 f5 ff ff       	call   8008fb <fd_alloc>
  801313:	89 c3                	mov    %eax,%ebx
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	85 c0                	test   %eax,%eax
  80131a:	0f 88 e2 00 00 00    	js     801402 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801320:	83 ec 04             	sub    $0x4,%esp
  801323:	68 07 04 00 00       	push   $0x407
  801328:	ff 75 f0             	pushl  -0x10(%ebp)
  80132b:	6a 00                	push   $0x0
  80132d:	e8 57 ee ff ff       	call   800189 <sys_page_alloc>
  801332:	89 c3                	mov    %eax,%ebx
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	0f 88 c3 00 00 00    	js     801402 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80133f:	83 ec 0c             	sub    $0xc,%esp
  801342:	ff 75 f4             	pushl  -0xc(%ebp)
  801345:	e8 9a f5 ff ff       	call   8008e4 <fd2data>
  80134a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80134c:	83 c4 0c             	add    $0xc,%esp
  80134f:	68 07 04 00 00       	push   $0x407
  801354:	50                   	push   %eax
  801355:	6a 00                	push   $0x0
  801357:	e8 2d ee ff ff       	call   800189 <sys_page_alloc>
  80135c:	89 c3                	mov    %eax,%ebx
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	85 c0                	test   %eax,%eax
  801363:	0f 88 89 00 00 00    	js     8013f2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801369:	83 ec 0c             	sub    $0xc,%esp
  80136c:	ff 75 f0             	pushl  -0x10(%ebp)
  80136f:	e8 70 f5 ff ff       	call   8008e4 <fd2data>
  801374:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80137b:	50                   	push   %eax
  80137c:	6a 00                	push   $0x0
  80137e:	56                   	push   %esi
  80137f:	6a 00                	push   $0x0
  801381:	e8 46 ee ff ff       	call   8001cc <sys_page_map>
  801386:	89 c3                	mov    %eax,%ebx
  801388:	83 c4 20             	add    $0x20,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 55                	js     8013e4 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80138f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801395:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801398:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80139a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8013a4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ad:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8013af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013b9:	83 ec 0c             	sub    $0xc,%esp
  8013bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8013bf:	e8 10 f5 ff ff       	call   8008d4 <fd2num>
  8013c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013c7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013c9:	83 c4 04             	add    $0x4,%esp
  8013cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8013cf:	e8 00 f5 ff ff       	call   8008d4 <fd2num>
  8013d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d7:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e2:	eb 30                	jmp    801414 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	56                   	push   %esi
  8013e8:	6a 00                	push   $0x0
  8013ea:	e8 1f ee ff ff       	call   80020e <sys_page_unmap>
  8013ef:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8013f8:	6a 00                	push   $0x0
  8013fa:	e8 0f ee ff ff       	call   80020e <sys_page_unmap>
  8013ff:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	ff 75 f4             	pushl  -0xc(%ebp)
  801408:	6a 00                	push   $0x0
  80140a:	e8 ff ed ff ff       	call   80020e <sys_page_unmap>
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801414:	89 d0                	mov    %edx,%eax
  801416:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801419:	5b                   	pop    %ebx
  80141a:	5e                   	pop    %esi
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    

0080141d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801423:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801426:	50                   	push   %eax
  801427:	ff 75 08             	pushl  0x8(%ebp)
  80142a:	e8 1b f5 ff ff       	call   80094a <fd_lookup>
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	85 c0                	test   %eax,%eax
  801434:	78 18                	js     80144e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801436:	83 ec 0c             	sub    $0xc,%esp
  801439:	ff 75 f4             	pushl  -0xc(%ebp)
  80143c:	e8 a3 f4 ff ff       	call   8008e4 <fd2data>
	return _pipeisclosed(fd, p);
  801441:	89 c2                	mov    %eax,%edx
  801443:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801446:	e8 18 fd ff ff       	call   801163 <_pipeisclosed>
  80144b:	83 c4 10             	add    $0x10,%esp
}
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801453:	b8 00 00 00 00       	mov    $0x0,%eax
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801460:	68 a6 25 80 00       	push   $0x8025a6
  801465:	ff 75 0c             	pushl  0xc(%ebp)
  801468:	e8 c4 07 00 00       	call   801c31 <strcpy>
	return 0;
}
  80146d:	b8 00 00 00 00       	mov    $0x0,%eax
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	57                   	push   %edi
  801478:	56                   	push   %esi
  801479:	53                   	push   %ebx
  80147a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801480:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801485:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80148b:	eb 2d                	jmp    8014ba <devcons_write+0x46>
		m = n - tot;
  80148d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801490:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801492:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801495:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80149a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80149d:	83 ec 04             	sub    $0x4,%esp
  8014a0:	53                   	push   %ebx
  8014a1:	03 45 0c             	add    0xc(%ebp),%eax
  8014a4:	50                   	push   %eax
  8014a5:	57                   	push   %edi
  8014a6:	e8 18 09 00 00       	call   801dc3 <memmove>
		sys_cputs(buf, m);
  8014ab:	83 c4 08             	add    $0x8,%esp
  8014ae:	53                   	push   %ebx
  8014af:	57                   	push   %edi
  8014b0:	e8 18 ec ff ff       	call   8000cd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014b5:	01 de                	add    %ebx,%esi
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	89 f0                	mov    %esi,%eax
  8014bc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014bf:	72 cc                	jb     80148d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c4:	5b                   	pop    %ebx
  8014c5:	5e                   	pop    %esi
  8014c6:	5f                   	pop    %edi
  8014c7:	5d                   	pop    %ebp
  8014c8:	c3                   	ret    

008014c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014d8:	74 2a                	je     801504 <devcons_read+0x3b>
  8014da:	eb 05                	jmp    8014e1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014dc:	e8 89 ec ff ff       	call   80016a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014e1:	e8 05 ec ff ff       	call   8000eb <sys_cgetc>
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	74 f2                	je     8014dc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 16                	js     801504 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014ee:	83 f8 04             	cmp    $0x4,%eax
  8014f1:	74 0c                	je     8014ff <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f6:	88 02                	mov    %al,(%edx)
	return 1;
  8014f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fd:	eb 05                	jmp    801504 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014ff:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80150c:	8b 45 08             	mov    0x8(%ebp),%eax
  80150f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801512:	6a 01                	push   $0x1
  801514:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801517:	50                   	push   %eax
  801518:	e8 b0 eb ff ff       	call   8000cd <sys_cputs>
}
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	c9                   	leave  
  801521:	c3                   	ret    

00801522 <getchar>:

int
getchar(void)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801528:	6a 01                	push   $0x1
  80152a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80152d:	50                   	push   %eax
  80152e:	6a 00                	push   $0x0
  801530:	e8 7e f6 ff ff       	call   800bb3 <read>
	if (r < 0)
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 0f                	js     80154b <getchar+0x29>
		return r;
	if (r < 1)
  80153c:	85 c0                	test   %eax,%eax
  80153e:	7e 06                	jle    801546 <getchar+0x24>
		return -E_EOF;
	return c;
  801540:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801544:	eb 05                	jmp    80154b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801546:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80154b:	c9                   	leave  
  80154c:	c3                   	ret    

0080154d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801553:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801556:	50                   	push   %eax
  801557:	ff 75 08             	pushl  0x8(%ebp)
  80155a:	e8 eb f3 ff ff       	call   80094a <fd_lookup>
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	85 c0                	test   %eax,%eax
  801564:	78 11                	js     801577 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801566:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801569:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80156f:	39 10                	cmp    %edx,(%eax)
  801571:	0f 94 c0             	sete   %al
  801574:	0f b6 c0             	movzbl %al,%eax
}
  801577:	c9                   	leave  
  801578:	c3                   	ret    

00801579 <opencons>:

int
opencons(void)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80157f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801582:	50                   	push   %eax
  801583:	e8 73 f3 ff ff       	call   8008fb <fd_alloc>
  801588:	83 c4 10             	add    $0x10,%esp
		return r;
  80158b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 3e                	js     8015cf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801591:	83 ec 04             	sub    $0x4,%esp
  801594:	68 07 04 00 00       	push   $0x407
  801599:	ff 75 f4             	pushl  -0xc(%ebp)
  80159c:	6a 00                	push   $0x0
  80159e:	e8 e6 eb ff ff       	call   800189 <sys_page_alloc>
  8015a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8015a6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 23                	js     8015cf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8015ac:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ba:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015c1:	83 ec 0c             	sub    $0xc,%esp
  8015c4:	50                   	push   %eax
  8015c5:	e8 0a f3 ff ff       	call   8008d4 <fd2num>
  8015ca:	89 c2                	mov    %eax,%edx
  8015cc:	83 c4 10             	add    $0x10,%esp
}
  8015cf:	89 d0                	mov    %edx,%eax
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    

008015d3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	56                   	push   %esi
  8015d7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015d8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015db:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015e1:	e8 65 eb ff ff       	call   80014b <sys_getenvid>
  8015e6:	83 ec 0c             	sub    $0xc,%esp
  8015e9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ec:	ff 75 08             	pushl  0x8(%ebp)
  8015ef:	56                   	push   %esi
  8015f0:	50                   	push   %eax
  8015f1:	68 b4 25 80 00       	push   $0x8025b4
  8015f6:	e8 b1 00 00 00       	call   8016ac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015fb:	83 c4 18             	add    $0x18,%esp
  8015fe:	53                   	push   %ebx
  8015ff:	ff 75 10             	pushl  0x10(%ebp)
  801602:	e8 54 00 00 00       	call   80165b <vcprintf>
	cprintf("\n");
  801607:	c7 04 24 ab 24 80 00 	movl   $0x8024ab,(%esp)
  80160e:	e8 99 00 00 00       	call   8016ac <cprintf>
  801613:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801616:	cc                   	int3   
  801617:	eb fd                	jmp    801616 <_panic+0x43>

00801619 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	53                   	push   %ebx
  80161d:	83 ec 04             	sub    $0x4,%esp
  801620:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801623:	8b 13                	mov    (%ebx),%edx
  801625:	8d 42 01             	lea    0x1(%edx),%eax
  801628:	89 03                	mov    %eax,(%ebx)
  80162a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80162d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801631:	3d ff 00 00 00       	cmp    $0xff,%eax
  801636:	75 1a                	jne    801652 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801638:	83 ec 08             	sub    $0x8,%esp
  80163b:	68 ff 00 00 00       	push   $0xff
  801640:	8d 43 08             	lea    0x8(%ebx),%eax
  801643:	50                   	push   %eax
  801644:	e8 84 ea ff ff       	call   8000cd <sys_cputs>
		b->idx = 0;
  801649:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80164f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801652:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801656:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801664:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80166b:	00 00 00 
	b.cnt = 0;
  80166e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801675:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801678:	ff 75 0c             	pushl  0xc(%ebp)
  80167b:	ff 75 08             	pushl  0x8(%ebp)
  80167e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801684:	50                   	push   %eax
  801685:	68 19 16 80 00       	push   $0x801619
  80168a:	e8 54 01 00 00       	call   8017e3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80168f:	83 c4 08             	add    $0x8,%esp
  801692:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801698:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80169e:	50                   	push   %eax
  80169f:	e8 29 ea ff ff       	call   8000cd <sys_cputs>

	return b.cnt;
}
  8016a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016b5:	50                   	push   %eax
  8016b6:	ff 75 08             	pushl  0x8(%ebp)
  8016b9:	e8 9d ff ff ff       	call   80165b <vcprintf>
	va_end(ap);

	return cnt;
}
  8016be:	c9                   	leave  
  8016bf:	c3                   	ret    

008016c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	57                   	push   %edi
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 1c             	sub    $0x1c,%esp
  8016c9:	89 c7                	mov    %eax,%edi
  8016cb:	89 d6                	mov    %edx,%esi
  8016cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016e4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016e7:	39 d3                	cmp    %edx,%ebx
  8016e9:	72 05                	jb     8016f0 <printnum+0x30>
  8016eb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016ee:	77 45                	ja     801735 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016f0:	83 ec 0c             	sub    $0xc,%esp
  8016f3:	ff 75 18             	pushl  0x18(%ebp)
  8016f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8016f9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8016fc:	53                   	push   %ebx
  8016fd:	ff 75 10             	pushl  0x10(%ebp)
  801700:	83 ec 08             	sub    $0x8,%esp
  801703:	ff 75 e4             	pushl  -0x1c(%ebp)
  801706:	ff 75 e0             	pushl  -0x20(%ebp)
  801709:	ff 75 dc             	pushl  -0x24(%ebp)
  80170c:	ff 75 d8             	pushl  -0x28(%ebp)
  80170f:	e8 5c 0a 00 00       	call   802170 <__udivdi3>
  801714:	83 c4 18             	add    $0x18,%esp
  801717:	52                   	push   %edx
  801718:	50                   	push   %eax
  801719:	89 f2                	mov    %esi,%edx
  80171b:	89 f8                	mov    %edi,%eax
  80171d:	e8 9e ff ff ff       	call   8016c0 <printnum>
  801722:	83 c4 20             	add    $0x20,%esp
  801725:	eb 18                	jmp    80173f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801727:	83 ec 08             	sub    $0x8,%esp
  80172a:	56                   	push   %esi
  80172b:	ff 75 18             	pushl  0x18(%ebp)
  80172e:	ff d7                	call   *%edi
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	eb 03                	jmp    801738 <printnum+0x78>
  801735:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801738:	83 eb 01             	sub    $0x1,%ebx
  80173b:	85 db                	test   %ebx,%ebx
  80173d:	7f e8                	jg     801727 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	56                   	push   %esi
  801743:	83 ec 04             	sub    $0x4,%esp
  801746:	ff 75 e4             	pushl  -0x1c(%ebp)
  801749:	ff 75 e0             	pushl  -0x20(%ebp)
  80174c:	ff 75 dc             	pushl  -0x24(%ebp)
  80174f:	ff 75 d8             	pushl  -0x28(%ebp)
  801752:	e8 49 0b 00 00       	call   8022a0 <__umoddi3>
  801757:	83 c4 14             	add    $0x14,%esp
  80175a:	0f be 80 d7 25 80 00 	movsbl 0x8025d7(%eax),%eax
  801761:	50                   	push   %eax
  801762:	ff d7                	call   *%edi
}
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80176a:	5b                   	pop    %ebx
  80176b:	5e                   	pop    %esi
  80176c:	5f                   	pop    %edi
  80176d:	5d                   	pop    %ebp
  80176e:	c3                   	ret    

0080176f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801772:	83 fa 01             	cmp    $0x1,%edx
  801775:	7e 0e                	jle    801785 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801777:	8b 10                	mov    (%eax),%edx
  801779:	8d 4a 08             	lea    0x8(%edx),%ecx
  80177c:	89 08                	mov    %ecx,(%eax)
  80177e:	8b 02                	mov    (%edx),%eax
  801780:	8b 52 04             	mov    0x4(%edx),%edx
  801783:	eb 22                	jmp    8017a7 <getuint+0x38>
	else if (lflag)
  801785:	85 d2                	test   %edx,%edx
  801787:	74 10                	je     801799 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801789:	8b 10                	mov    (%eax),%edx
  80178b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80178e:	89 08                	mov    %ecx,(%eax)
  801790:	8b 02                	mov    (%edx),%eax
  801792:	ba 00 00 00 00       	mov    $0x0,%edx
  801797:	eb 0e                	jmp    8017a7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801799:	8b 10                	mov    (%eax),%edx
  80179b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80179e:	89 08                	mov    %ecx,(%eax)
  8017a0:	8b 02                	mov    (%edx),%eax
  8017a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017a7:	5d                   	pop    %ebp
  8017a8:	c3                   	ret    

008017a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017b3:	8b 10                	mov    (%eax),%edx
  8017b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8017b8:	73 0a                	jae    8017c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8017ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017bd:	89 08                	mov    %ecx,(%eax)
  8017bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c2:	88 02                	mov    %al,(%edx)
}
  8017c4:	5d                   	pop    %ebp
  8017c5:	c3                   	ret    

008017c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017cf:	50                   	push   %eax
  8017d0:	ff 75 10             	pushl  0x10(%ebp)
  8017d3:	ff 75 0c             	pushl  0xc(%ebp)
  8017d6:	ff 75 08             	pushl  0x8(%ebp)
  8017d9:	e8 05 00 00 00       	call   8017e3 <vprintfmt>
	va_end(ap);
}
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	c9                   	leave  
  8017e2:	c3                   	ret    

008017e3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	57                   	push   %edi
  8017e7:	56                   	push   %esi
  8017e8:	53                   	push   %ebx
  8017e9:	83 ec 2c             	sub    $0x2c,%esp
  8017ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8017ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017f2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017f5:	eb 12                	jmp    801809 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	0f 84 89 03 00 00    	je     801b88 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8017ff:	83 ec 08             	sub    $0x8,%esp
  801802:	53                   	push   %ebx
  801803:	50                   	push   %eax
  801804:	ff d6                	call   *%esi
  801806:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801809:	83 c7 01             	add    $0x1,%edi
  80180c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801810:	83 f8 25             	cmp    $0x25,%eax
  801813:	75 e2                	jne    8017f7 <vprintfmt+0x14>
  801815:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801819:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801820:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801827:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80182e:	ba 00 00 00 00       	mov    $0x0,%edx
  801833:	eb 07                	jmp    80183c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801835:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801838:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183c:	8d 47 01             	lea    0x1(%edi),%eax
  80183f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801842:	0f b6 07             	movzbl (%edi),%eax
  801845:	0f b6 c8             	movzbl %al,%ecx
  801848:	83 e8 23             	sub    $0x23,%eax
  80184b:	3c 55                	cmp    $0x55,%al
  80184d:	0f 87 1a 03 00 00    	ja     801b6d <vprintfmt+0x38a>
  801853:	0f b6 c0             	movzbl %al,%eax
  801856:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  80185d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801860:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801864:	eb d6                	jmp    80183c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801866:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801869:	b8 00 00 00 00       	mov    $0x0,%eax
  80186e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801871:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801874:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801878:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80187b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80187e:	83 fa 09             	cmp    $0x9,%edx
  801881:	77 39                	ja     8018bc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801883:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801886:	eb e9                	jmp    801871 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801888:	8b 45 14             	mov    0x14(%ebp),%eax
  80188b:	8d 48 04             	lea    0x4(%eax),%ecx
  80188e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801891:	8b 00                	mov    (%eax),%eax
  801893:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801896:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801899:	eb 27                	jmp    8018c2 <vprintfmt+0xdf>
  80189b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018a5:	0f 49 c8             	cmovns %eax,%ecx
  8018a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018ae:	eb 8c                	jmp    80183c <vprintfmt+0x59>
  8018b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018b3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018ba:	eb 80                	jmp    80183c <vprintfmt+0x59>
  8018bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018bf:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018c6:	0f 89 70 ff ff ff    	jns    80183c <vprintfmt+0x59>
				width = precision, precision = -1;
  8018cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018d2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018d9:	e9 5e ff ff ff       	jmp    80183c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018de:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018e4:	e9 53 ff ff ff       	jmp    80183c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ec:	8d 50 04             	lea    0x4(%eax),%edx
  8018ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8018f2:	83 ec 08             	sub    $0x8,%esp
  8018f5:	53                   	push   %ebx
  8018f6:	ff 30                	pushl  (%eax)
  8018f8:	ff d6                	call   *%esi
			break;
  8018fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801900:	e9 04 ff ff ff       	jmp    801809 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801905:	8b 45 14             	mov    0x14(%ebp),%eax
  801908:	8d 50 04             	lea    0x4(%eax),%edx
  80190b:	89 55 14             	mov    %edx,0x14(%ebp)
  80190e:	8b 00                	mov    (%eax),%eax
  801910:	99                   	cltd   
  801911:	31 d0                	xor    %edx,%eax
  801913:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801915:	83 f8 0f             	cmp    $0xf,%eax
  801918:	7f 0b                	jg     801925 <vprintfmt+0x142>
  80191a:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  801921:	85 d2                	test   %edx,%edx
  801923:	75 18                	jne    80193d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801925:	50                   	push   %eax
  801926:	68 ef 25 80 00       	push   $0x8025ef
  80192b:	53                   	push   %ebx
  80192c:	56                   	push   %esi
  80192d:	e8 94 fe ff ff       	call   8017c6 <printfmt>
  801932:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801935:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801938:	e9 cc fe ff ff       	jmp    801809 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80193d:	52                   	push   %edx
  80193e:	68 6d 25 80 00       	push   $0x80256d
  801943:	53                   	push   %ebx
  801944:	56                   	push   %esi
  801945:	e8 7c fe ff ff       	call   8017c6 <printfmt>
  80194a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80194d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801950:	e9 b4 fe ff ff       	jmp    801809 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801955:	8b 45 14             	mov    0x14(%ebp),%eax
  801958:	8d 50 04             	lea    0x4(%eax),%edx
  80195b:	89 55 14             	mov    %edx,0x14(%ebp)
  80195e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801960:	85 ff                	test   %edi,%edi
  801962:	b8 e8 25 80 00       	mov    $0x8025e8,%eax
  801967:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80196a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80196e:	0f 8e 94 00 00 00    	jle    801a08 <vprintfmt+0x225>
  801974:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801978:	0f 84 98 00 00 00    	je     801a16 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80197e:	83 ec 08             	sub    $0x8,%esp
  801981:	ff 75 d0             	pushl  -0x30(%ebp)
  801984:	57                   	push   %edi
  801985:	e8 86 02 00 00       	call   801c10 <strnlen>
  80198a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80198d:	29 c1                	sub    %eax,%ecx
  80198f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801992:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801995:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801999:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80199c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80199f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019a1:	eb 0f                	jmp    8019b2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8019a3:	83 ec 08             	sub    $0x8,%esp
  8019a6:	53                   	push   %ebx
  8019a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8019aa:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019ac:	83 ef 01             	sub    $0x1,%edi
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	85 ff                	test   %edi,%edi
  8019b4:	7f ed                	jg     8019a3 <vprintfmt+0x1c0>
  8019b6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019b9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019bc:	85 c9                	test   %ecx,%ecx
  8019be:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c3:	0f 49 c1             	cmovns %ecx,%eax
  8019c6:	29 c1                	sub    %eax,%ecx
  8019c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8019cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019d1:	89 cb                	mov    %ecx,%ebx
  8019d3:	eb 4d                	jmp    801a22 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019d5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019d9:	74 1b                	je     8019f6 <vprintfmt+0x213>
  8019db:	0f be c0             	movsbl %al,%eax
  8019de:	83 e8 20             	sub    $0x20,%eax
  8019e1:	83 f8 5e             	cmp    $0x5e,%eax
  8019e4:	76 10                	jbe    8019f6 <vprintfmt+0x213>
					putch('?', putdat);
  8019e6:	83 ec 08             	sub    $0x8,%esp
  8019e9:	ff 75 0c             	pushl  0xc(%ebp)
  8019ec:	6a 3f                	push   $0x3f
  8019ee:	ff 55 08             	call   *0x8(%ebp)
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	eb 0d                	jmp    801a03 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019f6:	83 ec 08             	sub    $0x8,%esp
  8019f9:	ff 75 0c             	pushl  0xc(%ebp)
  8019fc:	52                   	push   %edx
  8019fd:	ff 55 08             	call   *0x8(%ebp)
  801a00:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a03:	83 eb 01             	sub    $0x1,%ebx
  801a06:	eb 1a                	jmp    801a22 <vprintfmt+0x23f>
  801a08:	89 75 08             	mov    %esi,0x8(%ebp)
  801a0b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a0e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a11:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a14:	eb 0c                	jmp    801a22 <vprintfmt+0x23f>
  801a16:	89 75 08             	mov    %esi,0x8(%ebp)
  801a19:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a1c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a1f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a22:	83 c7 01             	add    $0x1,%edi
  801a25:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a29:	0f be d0             	movsbl %al,%edx
  801a2c:	85 d2                	test   %edx,%edx
  801a2e:	74 23                	je     801a53 <vprintfmt+0x270>
  801a30:	85 f6                	test   %esi,%esi
  801a32:	78 a1                	js     8019d5 <vprintfmt+0x1f2>
  801a34:	83 ee 01             	sub    $0x1,%esi
  801a37:	79 9c                	jns    8019d5 <vprintfmt+0x1f2>
  801a39:	89 df                	mov    %ebx,%edi
  801a3b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a41:	eb 18                	jmp    801a5b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a43:	83 ec 08             	sub    $0x8,%esp
  801a46:	53                   	push   %ebx
  801a47:	6a 20                	push   $0x20
  801a49:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a4b:	83 ef 01             	sub    $0x1,%edi
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	eb 08                	jmp    801a5b <vprintfmt+0x278>
  801a53:	89 df                	mov    %ebx,%edi
  801a55:	8b 75 08             	mov    0x8(%ebp),%esi
  801a58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a5b:	85 ff                	test   %edi,%edi
  801a5d:	7f e4                	jg     801a43 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a62:	e9 a2 fd ff ff       	jmp    801809 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a67:	83 fa 01             	cmp    $0x1,%edx
  801a6a:	7e 16                	jle    801a82 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a6c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6f:	8d 50 08             	lea    0x8(%eax),%edx
  801a72:	89 55 14             	mov    %edx,0x14(%ebp)
  801a75:	8b 50 04             	mov    0x4(%eax),%edx
  801a78:	8b 00                	mov    (%eax),%eax
  801a7a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a7d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a80:	eb 32                	jmp    801ab4 <vprintfmt+0x2d1>
	else if (lflag)
  801a82:	85 d2                	test   %edx,%edx
  801a84:	74 18                	je     801a9e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a86:	8b 45 14             	mov    0x14(%ebp),%eax
  801a89:	8d 50 04             	lea    0x4(%eax),%edx
  801a8c:	89 55 14             	mov    %edx,0x14(%ebp)
  801a8f:	8b 00                	mov    (%eax),%eax
  801a91:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a94:	89 c1                	mov    %eax,%ecx
  801a96:	c1 f9 1f             	sar    $0x1f,%ecx
  801a99:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a9c:	eb 16                	jmp    801ab4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a9e:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa1:	8d 50 04             	lea    0x4(%eax),%edx
  801aa4:	89 55 14             	mov    %edx,0x14(%ebp)
  801aa7:	8b 00                	mov    (%eax),%eax
  801aa9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aac:	89 c1                	mov    %eax,%ecx
  801aae:	c1 f9 1f             	sar    $0x1f,%ecx
  801ab1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ab4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ab7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801aba:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801abf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ac3:	79 74                	jns    801b39 <vprintfmt+0x356>
				putch('-', putdat);
  801ac5:	83 ec 08             	sub    $0x8,%esp
  801ac8:	53                   	push   %ebx
  801ac9:	6a 2d                	push   $0x2d
  801acb:	ff d6                	call   *%esi
				num = -(long long) num;
  801acd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ad0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ad3:	f7 d8                	neg    %eax
  801ad5:	83 d2 00             	adc    $0x0,%edx
  801ad8:	f7 da                	neg    %edx
  801ada:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801add:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ae2:	eb 55                	jmp    801b39 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ae4:	8d 45 14             	lea    0x14(%ebp),%eax
  801ae7:	e8 83 fc ff ff       	call   80176f <getuint>
			base = 10;
  801aec:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801af1:	eb 46                	jmp    801b39 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801af3:	8d 45 14             	lea    0x14(%ebp),%eax
  801af6:	e8 74 fc ff ff       	call   80176f <getuint>
			base = 8;
  801afb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b00:	eb 37                	jmp    801b39 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b02:	83 ec 08             	sub    $0x8,%esp
  801b05:	53                   	push   %ebx
  801b06:	6a 30                	push   $0x30
  801b08:	ff d6                	call   *%esi
			putch('x', putdat);
  801b0a:	83 c4 08             	add    $0x8,%esp
  801b0d:	53                   	push   %ebx
  801b0e:	6a 78                	push   $0x78
  801b10:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b12:	8b 45 14             	mov    0x14(%ebp),%eax
  801b15:	8d 50 04             	lea    0x4(%eax),%edx
  801b18:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b1b:	8b 00                	mov    (%eax),%eax
  801b1d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b22:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b25:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b2a:	eb 0d                	jmp    801b39 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b2c:	8d 45 14             	lea    0x14(%ebp),%eax
  801b2f:	e8 3b fc ff ff       	call   80176f <getuint>
			base = 16;
  801b34:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b39:	83 ec 0c             	sub    $0xc,%esp
  801b3c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b40:	57                   	push   %edi
  801b41:	ff 75 e0             	pushl  -0x20(%ebp)
  801b44:	51                   	push   %ecx
  801b45:	52                   	push   %edx
  801b46:	50                   	push   %eax
  801b47:	89 da                	mov    %ebx,%edx
  801b49:	89 f0                	mov    %esi,%eax
  801b4b:	e8 70 fb ff ff       	call   8016c0 <printnum>
			break;
  801b50:	83 c4 20             	add    $0x20,%esp
  801b53:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b56:	e9 ae fc ff ff       	jmp    801809 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b5b:	83 ec 08             	sub    $0x8,%esp
  801b5e:	53                   	push   %ebx
  801b5f:	51                   	push   %ecx
  801b60:	ff d6                	call   *%esi
			break;
  801b62:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b68:	e9 9c fc ff ff       	jmp    801809 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b6d:	83 ec 08             	sub    $0x8,%esp
  801b70:	53                   	push   %ebx
  801b71:	6a 25                	push   $0x25
  801b73:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b75:	83 c4 10             	add    $0x10,%esp
  801b78:	eb 03                	jmp    801b7d <vprintfmt+0x39a>
  801b7a:	83 ef 01             	sub    $0x1,%edi
  801b7d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b81:	75 f7                	jne    801b7a <vprintfmt+0x397>
  801b83:	e9 81 fc ff ff       	jmp    801809 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8b:	5b                   	pop    %ebx
  801b8c:	5e                   	pop    %esi
  801b8d:	5f                   	pop    %edi
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    

00801b90 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 18             	sub    $0x18,%esp
  801b96:	8b 45 08             	mov    0x8(%ebp),%eax
  801b99:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b9f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ba3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ba6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801bad:	85 c0                	test   %eax,%eax
  801baf:	74 26                	je     801bd7 <vsnprintf+0x47>
  801bb1:	85 d2                	test   %edx,%edx
  801bb3:	7e 22                	jle    801bd7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801bb5:	ff 75 14             	pushl  0x14(%ebp)
  801bb8:	ff 75 10             	pushl  0x10(%ebp)
  801bbb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bbe:	50                   	push   %eax
  801bbf:	68 a9 17 80 00       	push   $0x8017a9
  801bc4:	e8 1a fc ff ff       	call   8017e3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bcc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	eb 05                	jmp    801bdc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bd7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bdc:	c9                   	leave  
  801bdd:	c3                   	ret    

00801bde <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801be4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801be7:	50                   	push   %eax
  801be8:	ff 75 10             	pushl  0x10(%ebp)
  801beb:	ff 75 0c             	pushl  0xc(%ebp)
  801bee:	ff 75 08             	pushl  0x8(%ebp)
  801bf1:	e8 9a ff ff ff       	call   801b90 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bf6:	c9                   	leave  
  801bf7:	c3                   	ret    

00801bf8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bfe:	b8 00 00 00 00       	mov    $0x0,%eax
  801c03:	eb 03                	jmp    801c08 <strlen+0x10>
		n++;
  801c05:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c08:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c0c:	75 f7                	jne    801c05 <strlen+0xd>
		n++;
	return n;
}
  801c0e:	5d                   	pop    %ebp
  801c0f:	c3                   	ret    

00801c10 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c16:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c19:	ba 00 00 00 00       	mov    $0x0,%edx
  801c1e:	eb 03                	jmp    801c23 <strnlen+0x13>
		n++;
  801c20:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c23:	39 c2                	cmp    %eax,%edx
  801c25:	74 08                	je     801c2f <strnlen+0x1f>
  801c27:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c2b:	75 f3                	jne    801c20 <strnlen+0x10>
  801c2d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    

00801c31 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	53                   	push   %ebx
  801c35:	8b 45 08             	mov    0x8(%ebp),%eax
  801c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c3b:	89 c2                	mov    %eax,%edx
  801c3d:	83 c2 01             	add    $0x1,%edx
  801c40:	83 c1 01             	add    $0x1,%ecx
  801c43:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c47:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c4a:	84 db                	test   %bl,%bl
  801c4c:	75 ef                	jne    801c3d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c4e:	5b                   	pop    %ebx
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    

00801c51 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	53                   	push   %ebx
  801c55:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c58:	53                   	push   %ebx
  801c59:	e8 9a ff ff ff       	call   801bf8 <strlen>
  801c5e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c61:	ff 75 0c             	pushl  0xc(%ebp)
  801c64:	01 d8                	add    %ebx,%eax
  801c66:	50                   	push   %eax
  801c67:	e8 c5 ff ff ff       	call   801c31 <strcpy>
	return dst;
}
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c71:	c9                   	leave  
  801c72:	c3                   	ret    

00801c73 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	56                   	push   %esi
  801c77:	53                   	push   %ebx
  801c78:	8b 75 08             	mov    0x8(%ebp),%esi
  801c7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c7e:	89 f3                	mov    %esi,%ebx
  801c80:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c83:	89 f2                	mov    %esi,%edx
  801c85:	eb 0f                	jmp    801c96 <strncpy+0x23>
		*dst++ = *src;
  801c87:	83 c2 01             	add    $0x1,%edx
  801c8a:	0f b6 01             	movzbl (%ecx),%eax
  801c8d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c90:	80 39 01             	cmpb   $0x1,(%ecx)
  801c93:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c96:	39 da                	cmp    %ebx,%edx
  801c98:	75 ed                	jne    801c87 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c9a:	89 f0                	mov    %esi,%eax
  801c9c:	5b                   	pop    %ebx
  801c9d:	5e                   	pop    %esi
  801c9e:	5d                   	pop    %ebp
  801c9f:	c3                   	ret    

00801ca0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	56                   	push   %esi
  801ca4:	53                   	push   %ebx
  801ca5:	8b 75 08             	mov    0x8(%ebp),%esi
  801ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cab:	8b 55 10             	mov    0x10(%ebp),%edx
  801cae:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801cb0:	85 d2                	test   %edx,%edx
  801cb2:	74 21                	je     801cd5 <strlcpy+0x35>
  801cb4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801cb8:	89 f2                	mov    %esi,%edx
  801cba:	eb 09                	jmp    801cc5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801cbc:	83 c2 01             	add    $0x1,%edx
  801cbf:	83 c1 01             	add    $0x1,%ecx
  801cc2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801cc5:	39 c2                	cmp    %eax,%edx
  801cc7:	74 09                	je     801cd2 <strlcpy+0x32>
  801cc9:	0f b6 19             	movzbl (%ecx),%ebx
  801ccc:	84 db                	test   %bl,%bl
  801cce:	75 ec                	jne    801cbc <strlcpy+0x1c>
  801cd0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801cd2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cd5:	29 f0                	sub    %esi,%eax
}
  801cd7:	5b                   	pop    %ebx
  801cd8:	5e                   	pop    %esi
  801cd9:	5d                   	pop    %ebp
  801cda:	c3                   	ret    

00801cdb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801ce4:	eb 06                	jmp    801cec <strcmp+0x11>
		p++, q++;
  801ce6:	83 c1 01             	add    $0x1,%ecx
  801ce9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801cec:	0f b6 01             	movzbl (%ecx),%eax
  801cef:	84 c0                	test   %al,%al
  801cf1:	74 04                	je     801cf7 <strcmp+0x1c>
  801cf3:	3a 02                	cmp    (%edx),%al
  801cf5:	74 ef                	je     801ce6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cf7:	0f b6 c0             	movzbl %al,%eax
  801cfa:	0f b6 12             	movzbl (%edx),%edx
  801cfd:	29 d0                	sub    %edx,%eax
}
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	53                   	push   %ebx
  801d05:	8b 45 08             	mov    0x8(%ebp),%eax
  801d08:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0b:	89 c3                	mov    %eax,%ebx
  801d0d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d10:	eb 06                	jmp    801d18 <strncmp+0x17>
		n--, p++, q++;
  801d12:	83 c0 01             	add    $0x1,%eax
  801d15:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d18:	39 d8                	cmp    %ebx,%eax
  801d1a:	74 15                	je     801d31 <strncmp+0x30>
  801d1c:	0f b6 08             	movzbl (%eax),%ecx
  801d1f:	84 c9                	test   %cl,%cl
  801d21:	74 04                	je     801d27 <strncmp+0x26>
  801d23:	3a 0a                	cmp    (%edx),%cl
  801d25:	74 eb                	je     801d12 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d27:	0f b6 00             	movzbl (%eax),%eax
  801d2a:	0f b6 12             	movzbl (%edx),%edx
  801d2d:	29 d0                	sub    %edx,%eax
  801d2f:	eb 05                	jmp    801d36 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d31:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d36:	5b                   	pop    %ebx
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    

00801d39 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d43:	eb 07                	jmp    801d4c <strchr+0x13>
		if (*s == c)
  801d45:	38 ca                	cmp    %cl,%dl
  801d47:	74 0f                	je     801d58 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d49:	83 c0 01             	add    $0x1,%eax
  801d4c:	0f b6 10             	movzbl (%eax),%edx
  801d4f:	84 d2                	test   %dl,%dl
  801d51:	75 f2                	jne    801d45 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d58:	5d                   	pop    %ebp
  801d59:	c3                   	ret    

00801d5a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d64:	eb 03                	jmp    801d69 <strfind+0xf>
  801d66:	83 c0 01             	add    $0x1,%eax
  801d69:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d6c:	38 ca                	cmp    %cl,%dl
  801d6e:	74 04                	je     801d74 <strfind+0x1a>
  801d70:	84 d2                	test   %dl,%dl
  801d72:	75 f2                	jne    801d66 <strfind+0xc>
			break;
	return (char *) s;
}
  801d74:	5d                   	pop    %ebp
  801d75:	c3                   	ret    

00801d76 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	57                   	push   %edi
  801d7a:	56                   	push   %esi
  801d7b:	53                   	push   %ebx
  801d7c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d82:	85 c9                	test   %ecx,%ecx
  801d84:	74 36                	je     801dbc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d86:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d8c:	75 28                	jne    801db6 <memset+0x40>
  801d8e:	f6 c1 03             	test   $0x3,%cl
  801d91:	75 23                	jne    801db6 <memset+0x40>
		c &= 0xFF;
  801d93:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d97:	89 d3                	mov    %edx,%ebx
  801d99:	c1 e3 08             	shl    $0x8,%ebx
  801d9c:	89 d6                	mov    %edx,%esi
  801d9e:	c1 e6 18             	shl    $0x18,%esi
  801da1:	89 d0                	mov    %edx,%eax
  801da3:	c1 e0 10             	shl    $0x10,%eax
  801da6:	09 f0                	or     %esi,%eax
  801da8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801daa:	89 d8                	mov    %ebx,%eax
  801dac:	09 d0                	or     %edx,%eax
  801dae:	c1 e9 02             	shr    $0x2,%ecx
  801db1:	fc                   	cld    
  801db2:	f3 ab                	rep stos %eax,%es:(%edi)
  801db4:	eb 06                	jmp    801dbc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801db6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db9:	fc                   	cld    
  801dba:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801dbc:	89 f8                	mov    %edi,%eax
  801dbe:	5b                   	pop    %ebx
  801dbf:	5e                   	pop    %esi
  801dc0:	5f                   	pop    %edi
  801dc1:	5d                   	pop    %ebp
  801dc2:	c3                   	ret    

00801dc3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	57                   	push   %edi
  801dc7:	56                   	push   %esi
  801dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801dd1:	39 c6                	cmp    %eax,%esi
  801dd3:	73 35                	jae    801e0a <memmove+0x47>
  801dd5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801dd8:	39 d0                	cmp    %edx,%eax
  801dda:	73 2e                	jae    801e0a <memmove+0x47>
		s += n;
		d += n;
  801ddc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ddf:	89 d6                	mov    %edx,%esi
  801de1:	09 fe                	or     %edi,%esi
  801de3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801de9:	75 13                	jne    801dfe <memmove+0x3b>
  801deb:	f6 c1 03             	test   $0x3,%cl
  801dee:	75 0e                	jne    801dfe <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801df0:	83 ef 04             	sub    $0x4,%edi
  801df3:	8d 72 fc             	lea    -0x4(%edx),%esi
  801df6:	c1 e9 02             	shr    $0x2,%ecx
  801df9:	fd                   	std    
  801dfa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dfc:	eb 09                	jmp    801e07 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801dfe:	83 ef 01             	sub    $0x1,%edi
  801e01:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e04:	fd                   	std    
  801e05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e07:	fc                   	cld    
  801e08:	eb 1d                	jmp    801e27 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e0a:	89 f2                	mov    %esi,%edx
  801e0c:	09 c2                	or     %eax,%edx
  801e0e:	f6 c2 03             	test   $0x3,%dl
  801e11:	75 0f                	jne    801e22 <memmove+0x5f>
  801e13:	f6 c1 03             	test   $0x3,%cl
  801e16:	75 0a                	jne    801e22 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e18:	c1 e9 02             	shr    $0x2,%ecx
  801e1b:	89 c7                	mov    %eax,%edi
  801e1d:	fc                   	cld    
  801e1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e20:	eb 05                	jmp    801e27 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e22:	89 c7                	mov    %eax,%edi
  801e24:	fc                   	cld    
  801e25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e27:	5e                   	pop    %esi
  801e28:	5f                   	pop    %edi
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    

00801e2b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e2e:	ff 75 10             	pushl  0x10(%ebp)
  801e31:	ff 75 0c             	pushl  0xc(%ebp)
  801e34:	ff 75 08             	pushl  0x8(%ebp)
  801e37:	e8 87 ff ff ff       	call   801dc3 <memmove>
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	56                   	push   %esi
  801e42:	53                   	push   %ebx
  801e43:	8b 45 08             	mov    0x8(%ebp),%eax
  801e46:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e49:	89 c6                	mov    %eax,%esi
  801e4b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e4e:	eb 1a                	jmp    801e6a <memcmp+0x2c>
		if (*s1 != *s2)
  801e50:	0f b6 08             	movzbl (%eax),%ecx
  801e53:	0f b6 1a             	movzbl (%edx),%ebx
  801e56:	38 d9                	cmp    %bl,%cl
  801e58:	74 0a                	je     801e64 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e5a:	0f b6 c1             	movzbl %cl,%eax
  801e5d:	0f b6 db             	movzbl %bl,%ebx
  801e60:	29 d8                	sub    %ebx,%eax
  801e62:	eb 0f                	jmp    801e73 <memcmp+0x35>
		s1++, s2++;
  801e64:	83 c0 01             	add    $0x1,%eax
  801e67:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e6a:	39 f0                	cmp    %esi,%eax
  801e6c:	75 e2                	jne    801e50 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5d                   	pop    %ebp
  801e76:	c3                   	ret    

00801e77 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	53                   	push   %ebx
  801e7b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e7e:	89 c1                	mov    %eax,%ecx
  801e80:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e83:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e87:	eb 0a                	jmp    801e93 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e89:	0f b6 10             	movzbl (%eax),%edx
  801e8c:	39 da                	cmp    %ebx,%edx
  801e8e:	74 07                	je     801e97 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e90:	83 c0 01             	add    $0x1,%eax
  801e93:	39 c8                	cmp    %ecx,%eax
  801e95:	72 f2                	jb     801e89 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e97:	5b                   	pop    %ebx
  801e98:	5d                   	pop    %ebp
  801e99:	c3                   	ret    

00801e9a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e9a:	55                   	push   %ebp
  801e9b:	89 e5                	mov    %esp,%ebp
  801e9d:	57                   	push   %edi
  801e9e:	56                   	push   %esi
  801e9f:	53                   	push   %ebx
  801ea0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ea3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ea6:	eb 03                	jmp    801eab <strtol+0x11>
		s++;
  801ea8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801eab:	0f b6 01             	movzbl (%ecx),%eax
  801eae:	3c 20                	cmp    $0x20,%al
  801eb0:	74 f6                	je     801ea8 <strtol+0xe>
  801eb2:	3c 09                	cmp    $0x9,%al
  801eb4:	74 f2                	je     801ea8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801eb6:	3c 2b                	cmp    $0x2b,%al
  801eb8:	75 0a                	jne    801ec4 <strtol+0x2a>
		s++;
  801eba:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ebd:	bf 00 00 00 00       	mov    $0x0,%edi
  801ec2:	eb 11                	jmp    801ed5 <strtol+0x3b>
  801ec4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ec9:	3c 2d                	cmp    $0x2d,%al
  801ecb:	75 08                	jne    801ed5 <strtol+0x3b>
		s++, neg = 1;
  801ecd:	83 c1 01             	add    $0x1,%ecx
  801ed0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ed5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801edb:	75 15                	jne    801ef2 <strtol+0x58>
  801edd:	80 39 30             	cmpb   $0x30,(%ecx)
  801ee0:	75 10                	jne    801ef2 <strtol+0x58>
  801ee2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ee6:	75 7c                	jne    801f64 <strtol+0xca>
		s += 2, base = 16;
  801ee8:	83 c1 02             	add    $0x2,%ecx
  801eeb:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ef0:	eb 16                	jmp    801f08 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ef2:	85 db                	test   %ebx,%ebx
  801ef4:	75 12                	jne    801f08 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ef6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801efb:	80 39 30             	cmpb   $0x30,(%ecx)
  801efe:	75 08                	jne    801f08 <strtol+0x6e>
		s++, base = 8;
  801f00:	83 c1 01             	add    $0x1,%ecx
  801f03:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f08:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f10:	0f b6 11             	movzbl (%ecx),%edx
  801f13:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f16:	89 f3                	mov    %esi,%ebx
  801f18:	80 fb 09             	cmp    $0x9,%bl
  801f1b:	77 08                	ja     801f25 <strtol+0x8b>
			dig = *s - '0';
  801f1d:	0f be d2             	movsbl %dl,%edx
  801f20:	83 ea 30             	sub    $0x30,%edx
  801f23:	eb 22                	jmp    801f47 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f25:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f28:	89 f3                	mov    %esi,%ebx
  801f2a:	80 fb 19             	cmp    $0x19,%bl
  801f2d:	77 08                	ja     801f37 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f2f:	0f be d2             	movsbl %dl,%edx
  801f32:	83 ea 57             	sub    $0x57,%edx
  801f35:	eb 10                	jmp    801f47 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f37:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f3a:	89 f3                	mov    %esi,%ebx
  801f3c:	80 fb 19             	cmp    $0x19,%bl
  801f3f:	77 16                	ja     801f57 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f41:	0f be d2             	movsbl %dl,%edx
  801f44:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f47:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f4a:	7d 0b                	jge    801f57 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f4c:	83 c1 01             	add    $0x1,%ecx
  801f4f:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f53:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f55:	eb b9                	jmp    801f10 <strtol+0x76>

	if (endptr)
  801f57:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f5b:	74 0d                	je     801f6a <strtol+0xd0>
		*endptr = (char *) s;
  801f5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f60:	89 0e                	mov    %ecx,(%esi)
  801f62:	eb 06                	jmp    801f6a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f64:	85 db                	test   %ebx,%ebx
  801f66:	74 98                	je     801f00 <strtol+0x66>
  801f68:	eb 9e                	jmp    801f08 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f6a:	89 c2                	mov    %eax,%edx
  801f6c:	f7 da                	neg    %edx
  801f6e:	85 ff                	test   %edi,%edi
  801f70:	0f 45 c2             	cmovne %edx,%eax
}
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5f                   	pop    %edi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    

00801f78 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f7e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f85:	75 2a                	jne    801fb1 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f87:	83 ec 04             	sub    $0x4,%esp
  801f8a:	6a 07                	push   $0x7
  801f8c:	68 00 f0 bf ee       	push   $0xeebff000
  801f91:	6a 00                	push   $0x0
  801f93:	e8 f1 e1 ff ff       	call   800189 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	79 12                	jns    801fb1 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f9f:	50                   	push   %eax
  801fa0:	68 c2 24 80 00       	push   $0x8024c2
  801fa5:	6a 23                	push   $0x23
  801fa7:	68 e0 28 80 00       	push   $0x8028e0
  801fac:	e8 22 f6 ff ff       	call   8015d3 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb4:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fb9:	83 ec 08             	sub    $0x8,%esp
  801fbc:	68 e3 1f 80 00       	push   $0x801fe3
  801fc1:	6a 00                	push   $0x0
  801fc3:	e8 0c e3 ff ff       	call   8002d4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fc8:	83 c4 10             	add    $0x10,%esp
  801fcb:	85 c0                	test   %eax,%eax
  801fcd:	79 12                	jns    801fe1 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fcf:	50                   	push   %eax
  801fd0:	68 c2 24 80 00       	push   $0x8024c2
  801fd5:	6a 2c                	push   $0x2c
  801fd7:	68 e0 28 80 00       	push   $0x8028e0
  801fdc:	e8 f2 f5 ff ff       	call   8015d3 <_panic>
	}
}
  801fe1:	c9                   	leave  
  801fe2:	c3                   	ret    

00801fe3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fe3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fe4:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fe9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801feb:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801fee:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801ff2:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801ff7:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801ffb:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801ffd:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802000:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802001:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802004:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802005:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802006:	c3                   	ret    

00802007 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802007:	55                   	push   %ebp
  802008:	89 e5                	mov    %esp,%ebp
  80200a:	56                   	push   %esi
  80200b:	53                   	push   %ebx
  80200c:	8b 75 08             	mov    0x8(%ebp),%esi
  80200f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802012:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802015:	85 c0                	test   %eax,%eax
  802017:	75 12                	jne    80202b <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802019:	83 ec 0c             	sub    $0xc,%esp
  80201c:	68 00 00 c0 ee       	push   $0xeec00000
  802021:	e8 13 e3 ff ff       	call   800339 <sys_ipc_recv>
  802026:	83 c4 10             	add    $0x10,%esp
  802029:	eb 0c                	jmp    802037 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80202b:	83 ec 0c             	sub    $0xc,%esp
  80202e:	50                   	push   %eax
  80202f:	e8 05 e3 ff ff       	call   800339 <sys_ipc_recv>
  802034:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802037:	85 f6                	test   %esi,%esi
  802039:	0f 95 c1             	setne  %cl
  80203c:	85 db                	test   %ebx,%ebx
  80203e:	0f 95 c2             	setne  %dl
  802041:	84 d1                	test   %dl,%cl
  802043:	74 09                	je     80204e <ipc_recv+0x47>
  802045:	89 c2                	mov    %eax,%edx
  802047:	c1 ea 1f             	shr    $0x1f,%edx
  80204a:	84 d2                	test   %dl,%dl
  80204c:	75 2d                	jne    80207b <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80204e:	85 f6                	test   %esi,%esi
  802050:	74 0d                	je     80205f <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802052:	a1 04 40 80 00       	mov    0x804004,%eax
  802057:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  80205d:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80205f:	85 db                	test   %ebx,%ebx
  802061:	74 0d                	je     802070 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802063:	a1 04 40 80 00       	mov    0x804004,%eax
  802068:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80206e:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802070:	a1 04 40 80 00       	mov    0x804004,%eax
  802075:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80207b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80207e:	5b                   	pop    %ebx
  80207f:	5e                   	pop    %esi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    

00802082 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802082:	55                   	push   %ebp
  802083:	89 e5                	mov    %esp,%ebp
  802085:	57                   	push   %edi
  802086:	56                   	push   %esi
  802087:	53                   	push   %ebx
  802088:	83 ec 0c             	sub    $0xc,%esp
  80208b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80208e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802091:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802094:	85 db                	test   %ebx,%ebx
  802096:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80209b:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80209e:	ff 75 14             	pushl  0x14(%ebp)
  8020a1:	53                   	push   %ebx
  8020a2:	56                   	push   %esi
  8020a3:	57                   	push   %edi
  8020a4:	e8 6d e2 ff ff       	call   800316 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020a9:	89 c2                	mov    %eax,%edx
  8020ab:	c1 ea 1f             	shr    $0x1f,%edx
  8020ae:	83 c4 10             	add    $0x10,%esp
  8020b1:	84 d2                	test   %dl,%dl
  8020b3:	74 17                	je     8020cc <ipc_send+0x4a>
  8020b5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020b8:	74 12                	je     8020cc <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020ba:	50                   	push   %eax
  8020bb:	68 ee 28 80 00       	push   $0x8028ee
  8020c0:	6a 47                	push   $0x47
  8020c2:	68 fc 28 80 00       	push   $0x8028fc
  8020c7:	e8 07 f5 ff ff       	call   8015d3 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020cc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020cf:	75 07                	jne    8020d8 <ipc_send+0x56>
			sys_yield();
  8020d1:	e8 94 e0 ff ff       	call   80016a <sys_yield>
  8020d6:	eb c6                	jmp    80209e <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020d8:	85 c0                	test   %eax,%eax
  8020da:	75 c2                	jne    80209e <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020df:	5b                   	pop    %ebx
  8020e0:	5e                   	pop    %esi
  8020e1:	5f                   	pop    %edi
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    

008020e4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020ea:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020ef:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8020f5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020fb:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802101:	39 ca                	cmp    %ecx,%edx
  802103:	75 13                	jne    802118 <ipc_find_env+0x34>
			return envs[i].env_id;
  802105:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80210b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802110:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802116:	eb 0f                	jmp    802127 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802118:	83 c0 01             	add    $0x1,%eax
  80211b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802120:	75 cd                	jne    8020ef <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802122:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    

00802129 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80212f:	89 d0                	mov    %edx,%eax
  802131:	c1 e8 16             	shr    $0x16,%eax
  802134:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80213b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802140:	f6 c1 01             	test   $0x1,%cl
  802143:	74 1d                	je     802162 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802145:	c1 ea 0c             	shr    $0xc,%edx
  802148:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80214f:	f6 c2 01             	test   $0x1,%dl
  802152:	74 0e                	je     802162 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802154:	c1 ea 0c             	shr    $0xc,%edx
  802157:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80215e:	ef 
  80215f:	0f b7 c0             	movzwl %ax,%eax
}
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    
  802164:	66 90                	xchg   %ax,%ax
  802166:	66 90                	xchg   %ax,%ax
  802168:	66 90                	xchg   %ax,%ax
  80216a:	66 90                	xchg   %ax,%ax
  80216c:	66 90                	xchg   %ax,%ax
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
