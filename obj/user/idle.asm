
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
  800039:	c7 05 00 30 80 00 20 	movl   $0x802220,0x803000
  800040:	22 80 00 
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
  80005f:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800065:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006a:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  8000b9:	e8 04 08 00 00       	call   8008c2 <close_all>
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
  800132:	68 2f 22 80 00       	push   $0x80222f
  800137:	6a 23                	push   $0x23
  800139:	68 4c 22 80 00       	push   $0x80224c
  80013e:	e8 b0 12 00 00       	call   8013f3 <_panic>

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
  8001b3:	68 2f 22 80 00       	push   $0x80222f
  8001b8:	6a 23                	push   $0x23
  8001ba:	68 4c 22 80 00       	push   $0x80224c
  8001bf:	e8 2f 12 00 00       	call   8013f3 <_panic>

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
  8001f5:	68 2f 22 80 00       	push   $0x80222f
  8001fa:	6a 23                	push   $0x23
  8001fc:	68 4c 22 80 00       	push   $0x80224c
  800201:	e8 ed 11 00 00       	call   8013f3 <_panic>

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
  800237:	68 2f 22 80 00       	push   $0x80222f
  80023c:	6a 23                	push   $0x23
  80023e:	68 4c 22 80 00       	push   $0x80224c
  800243:	e8 ab 11 00 00       	call   8013f3 <_panic>

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
  800279:	68 2f 22 80 00       	push   $0x80222f
  80027e:	6a 23                	push   $0x23
  800280:	68 4c 22 80 00       	push   $0x80224c
  800285:	e8 69 11 00 00       	call   8013f3 <_panic>

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
  8002bb:	68 2f 22 80 00       	push   $0x80222f
  8002c0:	6a 23                	push   $0x23
  8002c2:	68 4c 22 80 00       	push   $0x80224c
  8002c7:	e8 27 11 00 00       	call   8013f3 <_panic>
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
  8002fd:	68 2f 22 80 00       	push   $0x80222f
  800302:	6a 23                	push   $0x23
  800304:	68 4c 22 80 00       	push   $0x80224c
  800309:	e8 e5 10 00 00       	call   8013f3 <_panic>

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
  800361:	68 2f 22 80 00       	push   $0x80222f
  800366:	6a 23                	push   $0x23
  800368:	68 4c 22 80 00       	push   $0x80224c
  80036d:	e8 81 10 00 00       	call   8013f3 <_panic>

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
  800400:	68 5a 22 80 00       	push   $0x80225a
  800405:	6a 1e                	push   $0x1e
  800407:	68 6a 22 80 00       	push   $0x80226a
  80040c:	e8 e2 0f 00 00       	call   8013f3 <_panic>
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
  80042a:	68 75 22 80 00       	push   $0x802275
  80042f:	6a 2c                	push   $0x2c
  800431:	68 6a 22 80 00       	push   $0x80226a
  800436:	e8 b8 0f 00 00       	call   8013f3 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80043b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800441:	83 ec 04             	sub    $0x4,%esp
  800444:	68 00 10 00 00       	push   $0x1000
  800449:	53                   	push   %ebx
  80044a:	68 00 f0 7f 00       	push   $0x7ff000
  80044f:	e8 f7 17 00 00       	call   801c4b <memcpy>

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
  800472:	68 75 22 80 00       	push   $0x802275
  800477:	6a 33                	push   $0x33
  800479:	68 6a 22 80 00       	push   $0x80226a
  80047e:	e8 70 0f 00 00       	call   8013f3 <_panic>
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
  80049a:	68 75 22 80 00       	push   $0x802275
  80049f:	6a 37                	push   $0x37
  8004a1:	68 6a 22 80 00       	push   $0x80226a
  8004a6:	e8 48 0f 00 00       	call   8013f3 <_panic>
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
  8004be:	e8 d5 18 00 00       	call   801d98 <set_pgfault_handler>
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
  8004d7:	68 8e 22 80 00       	push   $0x80228e
  8004dc:	68 84 00 00 00       	push   $0x84
  8004e1:	68 6a 22 80 00       	push   $0x80226a
  8004e6:	e8 08 0f 00 00       	call   8013f3 <_panic>
  8004eb:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f1:	75 24                	jne    800517 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004f3:	e8 53 fc ff ff       	call   80014b <sys_getenvid>
  8004f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004fd:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800593:	68 9c 22 80 00       	push   $0x80229c
  800598:	6a 54                	push   $0x54
  80059a:	68 6a 22 80 00       	push   $0x80226a
  80059f:	e8 4f 0e 00 00       	call   8013f3 <_panic>
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
  8005d8:	68 9c 22 80 00       	push   $0x80229c
  8005dd:	6a 5b                	push   $0x5b
  8005df:	68 6a 22 80 00       	push   $0x80226a
  8005e4:	e8 0a 0e 00 00       	call   8013f3 <_panic>
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
  800606:	68 9c 22 80 00       	push   $0x80229c
  80060b:	6a 5f                	push   $0x5f
  80060d:	68 6a 22 80 00       	push   $0x80226a
  800612:	e8 dc 0d 00 00       	call   8013f3 <_panic>
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
  800630:	68 9c 22 80 00       	push   $0x80229c
  800635:	6a 64                	push   $0x64
  800637:	68 6a 22 80 00       	push   $0x80226a
  80063c:	e8 b2 0d 00 00       	call   8013f3 <_panic>
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
  800658:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	56                   	push   %esi
  800691:	53                   	push   %ebx
  800692:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800695:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	68 b4 22 80 00       	push   $0x8022b4
  8006a4:	e8 23 0e 00 00       	call   8014cc <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006a9:	c7 04 24 93 00 80 00 	movl   $0x800093,(%esp)
  8006b0:	e8 c5 fc ff ff       	call   80037a <sys_thread_create>
  8006b5:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006b7:	83 c4 08             	add    $0x8,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	68 b4 22 80 00       	push   $0x8022b4
  8006c0:	e8 07 0e 00 00       	call   8014cc <cprintf>
	return id;
}
  8006c5:	89 f0                	mov    %esi,%eax
  8006c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006ca:	5b                   	pop    %ebx
  8006cb:	5e                   	pop    %esi
  8006cc:	5d                   	pop    %ebp
  8006cd:	c3                   	ret    

008006ce <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8006d4:	ff 75 08             	pushl  0x8(%ebp)
  8006d7:	e8 be fc ff ff       	call   80039a <sys_thread_free>
}
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	c9                   	leave  
  8006e0:	c3                   	ret    

008006e1 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8006e7:	ff 75 08             	pushl  0x8(%ebp)
  8006ea:	e8 cb fc ff ff       	call   8003ba <sys_thread_join>
}
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8006ff:	c1 e8 0c             	shr    $0xc,%eax
}
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800707:	8b 45 08             	mov    0x8(%ebp),%eax
  80070a:	05 00 00 00 30       	add    $0x30000000,%eax
  80070f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800714:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800721:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800726:	89 c2                	mov    %eax,%edx
  800728:	c1 ea 16             	shr    $0x16,%edx
  80072b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800732:	f6 c2 01             	test   $0x1,%dl
  800735:	74 11                	je     800748 <fd_alloc+0x2d>
  800737:	89 c2                	mov    %eax,%edx
  800739:	c1 ea 0c             	shr    $0xc,%edx
  80073c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800743:	f6 c2 01             	test   $0x1,%dl
  800746:	75 09                	jne    800751 <fd_alloc+0x36>
			*fd_store = fd;
  800748:	89 01                	mov    %eax,(%ecx)
			return 0;
  80074a:	b8 00 00 00 00       	mov    $0x0,%eax
  80074f:	eb 17                	jmp    800768 <fd_alloc+0x4d>
  800751:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800756:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80075b:	75 c9                	jne    800726 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80075d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800763:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800770:	83 f8 1f             	cmp    $0x1f,%eax
  800773:	77 36                	ja     8007ab <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800775:	c1 e0 0c             	shl    $0xc,%eax
  800778:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	c1 ea 16             	shr    $0x16,%edx
  800782:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800789:	f6 c2 01             	test   $0x1,%dl
  80078c:	74 24                	je     8007b2 <fd_lookup+0x48>
  80078e:	89 c2                	mov    %eax,%edx
  800790:	c1 ea 0c             	shr    $0xc,%edx
  800793:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80079a:	f6 c2 01             	test   $0x1,%dl
  80079d:	74 1a                	je     8007b9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80079f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a2:	89 02                	mov    %eax,(%edx)
	return 0;
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a9:	eb 13                	jmp    8007be <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b0:	eb 0c                	jmp    8007be <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b7:	eb 05                	jmp    8007be <fd_lookup+0x54>
  8007b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 08             	sub    $0x8,%esp
  8007c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c9:	ba 54 23 80 00       	mov    $0x802354,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8007ce:	eb 13                	jmp    8007e3 <dev_lookup+0x23>
  8007d0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8007d3:	39 08                	cmp    %ecx,(%eax)
  8007d5:	75 0c                	jne    8007e3 <dev_lookup+0x23>
			*dev = devtab[i];
  8007d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007da:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	eb 31                	jmp    800814 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007e3:	8b 02                	mov    (%edx),%eax
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	75 e7                	jne    8007d0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8007ee:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8007f4:	83 ec 04             	sub    $0x4,%esp
  8007f7:	51                   	push   %ecx
  8007f8:	50                   	push   %eax
  8007f9:	68 d8 22 80 00       	push   $0x8022d8
  8007fe:	e8 c9 0c 00 00       	call   8014cc <cprintf>
	*dev = 0;
  800803:	8b 45 0c             	mov    0xc(%ebp),%eax
  800806:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80080c:	83 c4 10             	add    $0x10,%esp
  80080f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	83 ec 10             	sub    $0x10,%esp
  80081e:	8b 75 08             	mov    0x8(%ebp),%esi
  800821:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800824:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800827:	50                   	push   %eax
  800828:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80082e:	c1 e8 0c             	shr    $0xc,%eax
  800831:	50                   	push   %eax
  800832:	e8 33 ff ff ff       	call   80076a <fd_lookup>
  800837:	83 c4 08             	add    $0x8,%esp
  80083a:	85 c0                	test   %eax,%eax
  80083c:	78 05                	js     800843 <fd_close+0x2d>
	    || fd != fd2)
  80083e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800841:	74 0c                	je     80084f <fd_close+0x39>
		return (must_exist ? r : 0);
  800843:	84 db                	test   %bl,%bl
  800845:	ba 00 00 00 00       	mov    $0x0,%edx
  80084a:	0f 44 c2             	cmove  %edx,%eax
  80084d:	eb 41                	jmp    800890 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80084f:	83 ec 08             	sub    $0x8,%esp
  800852:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800855:	50                   	push   %eax
  800856:	ff 36                	pushl  (%esi)
  800858:	e8 63 ff ff ff       	call   8007c0 <dev_lookup>
  80085d:	89 c3                	mov    %eax,%ebx
  80085f:	83 c4 10             	add    $0x10,%esp
  800862:	85 c0                	test   %eax,%eax
  800864:	78 1a                	js     800880 <fd_close+0x6a>
		if (dev->dev_close)
  800866:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800869:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80086c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800871:	85 c0                	test   %eax,%eax
  800873:	74 0b                	je     800880 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800875:	83 ec 0c             	sub    $0xc,%esp
  800878:	56                   	push   %esi
  800879:	ff d0                	call   *%eax
  80087b:	89 c3                	mov    %eax,%ebx
  80087d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800880:	83 ec 08             	sub    $0x8,%esp
  800883:	56                   	push   %esi
  800884:	6a 00                	push   $0x0
  800886:	e8 83 f9 ff ff       	call   80020e <sys_page_unmap>
	return r;
  80088b:	83 c4 10             	add    $0x10,%esp
  80088e:	89 d8                	mov    %ebx,%eax
}
  800890:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800893:	5b                   	pop    %ebx
  800894:	5e                   	pop    %esi
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80089d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a0:	50                   	push   %eax
  8008a1:	ff 75 08             	pushl  0x8(%ebp)
  8008a4:	e8 c1 fe ff ff       	call   80076a <fd_lookup>
  8008a9:	83 c4 08             	add    $0x8,%esp
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	78 10                	js     8008c0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8008b0:	83 ec 08             	sub    $0x8,%esp
  8008b3:	6a 01                	push   $0x1
  8008b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8008b8:	e8 59 ff ff ff       	call   800816 <fd_close>
  8008bd:	83 c4 10             	add    $0x10,%esp
}
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    

008008c2 <close_all>:

void
close_all(void)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8008c9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8008ce:	83 ec 0c             	sub    $0xc,%esp
  8008d1:	53                   	push   %ebx
  8008d2:	e8 c0 ff ff ff       	call   800897 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8008d7:	83 c3 01             	add    $0x1,%ebx
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	83 fb 20             	cmp    $0x20,%ebx
  8008e0:	75 ec                	jne    8008ce <close_all+0xc>
		close(i);
}
  8008e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    

008008e7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	57                   	push   %edi
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
  8008ed:	83 ec 2c             	sub    $0x2c,%esp
  8008f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008f3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008f6:	50                   	push   %eax
  8008f7:	ff 75 08             	pushl  0x8(%ebp)
  8008fa:	e8 6b fe ff ff       	call   80076a <fd_lookup>
  8008ff:	83 c4 08             	add    $0x8,%esp
  800902:	85 c0                	test   %eax,%eax
  800904:	0f 88 c1 00 00 00    	js     8009cb <dup+0xe4>
		return r;
	close(newfdnum);
  80090a:	83 ec 0c             	sub    $0xc,%esp
  80090d:	56                   	push   %esi
  80090e:	e8 84 ff ff ff       	call   800897 <close>

	newfd = INDEX2FD(newfdnum);
  800913:	89 f3                	mov    %esi,%ebx
  800915:	c1 e3 0c             	shl    $0xc,%ebx
  800918:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80091e:	83 c4 04             	add    $0x4,%esp
  800921:	ff 75 e4             	pushl  -0x1c(%ebp)
  800924:	e8 db fd ff ff       	call   800704 <fd2data>
  800929:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80092b:	89 1c 24             	mov    %ebx,(%esp)
  80092e:	e8 d1 fd ff ff       	call   800704 <fd2data>
  800933:	83 c4 10             	add    $0x10,%esp
  800936:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800939:	89 f8                	mov    %edi,%eax
  80093b:	c1 e8 16             	shr    $0x16,%eax
  80093e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800945:	a8 01                	test   $0x1,%al
  800947:	74 37                	je     800980 <dup+0x99>
  800949:	89 f8                	mov    %edi,%eax
  80094b:	c1 e8 0c             	shr    $0xc,%eax
  80094e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800955:	f6 c2 01             	test   $0x1,%dl
  800958:	74 26                	je     800980 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80095a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800961:	83 ec 0c             	sub    $0xc,%esp
  800964:	25 07 0e 00 00       	and    $0xe07,%eax
  800969:	50                   	push   %eax
  80096a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80096d:	6a 00                	push   $0x0
  80096f:	57                   	push   %edi
  800970:	6a 00                	push   $0x0
  800972:	e8 55 f8 ff ff       	call   8001cc <sys_page_map>
  800977:	89 c7                	mov    %eax,%edi
  800979:	83 c4 20             	add    $0x20,%esp
  80097c:	85 c0                	test   %eax,%eax
  80097e:	78 2e                	js     8009ae <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800980:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800983:	89 d0                	mov    %edx,%eax
  800985:	c1 e8 0c             	shr    $0xc,%eax
  800988:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80098f:	83 ec 0c             	sub    $0xc,%esp
  800992:	25 07 0e 00 00       	and    $0xe07,%eax
  800997:	50                   	push   %eax
  800998:	53                   	push   %ebx
  800999:	6a 00                	push   $0x0
  80099b:	52                   	push   %edx
  80099c:	6a 00                	push   $0x0
  80099e:	e8 29 f8 ff ff       	call   8001cc <sys_page_map>
  8009a3:	89 c7                	mov    %eax,%edi
  8009a5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8009a8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009aa:	85 ff                	test   %edi,%edi
  8009ac:	79 1d                	jns    8009cb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8009ae:	83 ec 08             	sub    $0x8,%esp
  8009b1:	53                   	push   %ebx
  8009b2:	6a 00                	push   $0x0
  8009b4:	e8 55 f8 ff ff       	call   80020e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8009b9:	83 c4 08             	add    $0x8,%esp
  8009bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009bf:	6a 00                	push   $0x0
  8009c1:	e8 48 f8 ff ff       	call   80020e <sys_page_unmap>
	return r;
  8009c6:	83 c4 10             	add    $0x10,%esp
  8009c9:	89 f8                	mov    %edi,%eax
}
  8009cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009ce:	5b                   	pop    %ebx
  8009cf:	5e                   	pop    %esi
  8009d0:	5f                   	pop    %edi
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	53                   	push   %ebx
  8009d7:	83 ec 14             	sub    $0x14,%esp
  8009da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009e0:	50                   	push   %eax
  8009e1:	53                   	push   %ebx
  8009e2:	e8 83 fd ff ff       	call   80076a <fd_lookup>
  8009e7:	83 c4 08             	add    $0x8,%esp
  8009ea:	89 c2                	mov    %eax,%edx
  8009ec:	85 c0                	test   %eax,%eax
  8009ee:	78 70                	js     800a60 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009f0:	83 ec 08             	sub    $0x8,%esp
  8009f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009f6:	50                   	push   %eax
  8009f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009fa:	ff 30                	pushl  (%eax)
  8009fc:	e8 bf fd ff ff       	call   8007c0 <dev_lookup>
  800a01:	83 c4 10             	add    $0x10,%esp
  800a04:	85 c0                	test   %eax,%eax
  800a06:	78 4f                	js     800a57 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a08:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a0b:	8b 42 08             	mov    0x8(%edx),%eax
  800a0e:	83 e0 03             	and    $0x3,%eax
  800a11:	83 f8 01             	cmp    $0x1,%eax
  800a14:	75 24                	jne    800a3a <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a16:	a1 04 40 80 00       	mov    0x804004,%eax
  800a1b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a21:	83 ec 04             	sub    $0x4,%esp
  800a24:	53                   	push   %ebx
  800a25:	50                   	push   %eax
  800a26:	68 19 23 80 00       	push   $0x802319
  800a2b:	e8 9c 0a 00 00       	call   8014cc <cprintf>
		return -E_INVAL;
  800a30:	83 c4 10             	add    $0x10,%esp
  800a33:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800a38:	eb 26                	jmp    800a60 <read+0x8d>
	}
	if (!dev->dev_read)
  800a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a3d:	8b 40 08             	mov    0x8(%eax),%eax
  800a40:	85 c0                	test   %eax,%eax
  800a42:	74 17                	je     800a5b <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800a44:	83 ec 04             	sub    $0x4,%esp
  800a47:	ff 75 10             	pushl  0x10(%ebp)
  800a4a:	ff 75 0c             	pushl  0xc(%ebp)
  800a4d:	52                   	push   %edx
  800a4e:	ff d0                	call   *%eax
  800a50:	89 c2                	mov    %eax,%edx
  800a52:	83 c4 10             	add    $0x10,%esp
  800a55:	eb 09                	jmp    800a60 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a57:	89 c2                	mov    %eax,%edx
  800a59:	eb 05                	jmp    800a60 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a5b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a60:	89 d0                	mov    %edx,%eax
  800a62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    

00800a67 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	83 ec 0c             	sub    $0xc,%esp
  800a70:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a73:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a7b:	eb 21                	jmp    800a9e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a7d:	83 ec 04             	sub    $0x4,%esp
  800a80:	89 f0                	mov    %esi,%eax
  800a82:	29 d8                	sub    %ebx,%eax
  800a84:	50                   	push   %eax
  800a85:	89 d8                	mov    %ebx,%eax
  800a87:	03 45 0c             	add    0xc(%ebp),%eax
  800a8a:	50                   	push   %eax
  800a8b:	57                   	push   %edi
  800a8c:	e8 42 ff ff ff       	call   8009d3 <read>
		if (m < 0)
  800a91:	83 c4 10             	add    $0x10,%esp
  800a94:	85 c0                	test   %eax,%eax
  800a96:	78 10                	js     800aa8 <readn+0x41>
			return m;
		if (m == 0)
  800a98:	85 c0                	test   %eax,%eax
  800a9a:	74 0a                	je     800aa6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a9c:	01 c3                	add    %eax,%ebx
  800a9e:	39 f3                	cmp    %esi,%ebx
  800aa0:	72 db                	jb     800a7d <readn+0x16>
  800aa2:	89 d8                	mov    %ebx,%eax
  800aa4:	eb 02                	jmp    800aa8 <readn+0x41>
  800aa6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800aa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5f                   	pop    %edi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	53                   	push   %ebx
  800ab4:	83 ec 14             	sub    $0x14,%esp
  800ab7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800aba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800abd:	50                   	push   %eax
  800abe:	53                   	push   %ebx
  800abf:	e8 a6 fc ff ff       	call   80076a <fd_lookup>
  800ac4:	83 c4 08             	add    $0x8,%esp
  800ac7:	89 c2                	mov    %eax,%edx
  800ac9:	85 c0                	test   %eax,%eax
  800acb:	78 6b                	js     800b38 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800acd:	83 ec 08             	sub    $0x8,%esp
  800ad0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad3:	50                   	push   %eax
  800ad4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ad7:	ff 30                	pushl  (%eax)
  800ad9:	e8 e2 fc ff ff       	call   8007c0 <dev_lookup>
  800ade:	83 c4 10             	add    $0x10,%esp
  800ae1:	85 c0                	test   %eax,%eax
  800ae3:	78 4a                	js     800b2f <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ae8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800aec:	75 24                	jne    800b12 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800aee:	a1 04 40 80 00       	mov    0x804004,%eax
  800af3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800af9:	83 ec 04             	sub    $0x4,%esp
  800afc:	53                   	push   %ebx
  800afd:	50                   	push   %eax
  800afe:	68 35 23 80 00       	push   $0x802335
  800b03:	e8 c4 09 00 00       	call   8014cc <cprintf>
		return -E_INVAL;
  800b08:	83 c4 10             	add    $0x10,%esp
  800b0b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b10:	eb 26                	jmp    800b38 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b12:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b15:	8b 52 0c             	mov    0xc(%edx),%edx
  800b18:	85 d2                	test   %edx,%edx
  800b1a:	74 17                	je     800b33 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b1c:	83 ec 04             	sub    $0x4,%esp
  800b1f:	ff 75 10             	pushl  0x10(%ebp)
  800b22:	ff 75 0c             	pushl  0xc(%ebp)
  800b25:	50                   	push   %eax
  800b26:	ff d2                	call   *%edx
  800b28:	89 c2                	mov    %eax,%edx
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	eb 09                	jmp    800b38 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b2f:	89 c2                	mov    %eax,%edx
  800b31:	eb 05                	jmp    800b38 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800b33:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800b38:	89 d0                	mov    %edx,%eax
  800b3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    

00800b3f <seek>:

int
seek(int fdnum, off_t offset)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b45:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b48:	50                   	push   %eax
  800b49:	ff 75 08             	pushl  0x8(%ebp)
  800b4c:	e8 19 fc ff ff       	call   80076a <fd_lookup>
  800b51:	83 c4 08             	add    $0x8,%esp
  800b54:	85 c0                	test   %eax,%eax
  800b56:	78 0e                	js     800b66 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b58:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b61:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b66:	c9                   	leave  
  800b67:	c3                   	ret    

00800b68 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 14             	sub    $0x14,%esp
  800b6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b72:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b75:	50                   	push   %eax
  800b76:	53                   	push   %ebx
  800b77:	e8 ee fb ff ff       	call   80076a <fd_lookup>
  800b7c:	83 c4 08             	add    $0x8,%esp
  800b7f:	89 c2                	mov    %eax,%edx
  800b81:	85 c0                	test   %eax,%eax
  800b83:	78 68                	js     800bed <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b85:	83 ec 08             	sub    $0x8,%esp
  800b88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b8b:	50                   	push   %eax
  800b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b8f:	ff 30                	pushl  (%eax)
  800b91:	e8 2a fc ff ff       	call   8007c0 <dev_lookup>
  800b96:	83 c4 10             	add    $0x10,%esp
  800b99:	85 c0                	test   %eax,%eax
  800b9b:	78 47                	js     800be4 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ba0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ba4:	75 24                	jne    800bca <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800ba6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800bab:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800bb1:	83 ec 04             	sub    $0x4,%esp
  800bb4:	53                   	push   %ebx
  800bb5:	50                   	push   %eax
  800bb6:	68 f8 22 80 00       	push   $0x8022f8
  800bbb:	e8 0c 09 00 00       	call   8014cc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800bc0:	83 c4 10             	add    $0x10,%esp
  800bc3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800bc8:	eb 23                	jmp    800bed <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800bca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bcd:	8b 52 18             	mov    0x18(%edx),%edx
  800bd0:	85 d2                	test   %edx,%edx
  800bd2:	74 14                	je     800be8 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800bd4:	83 ec 08             	sub    $0x8,%esp
  800bd7:	ff 75 0c             	pushl  0xc(%ebp)
  800bda:	50                   	push   %eax
  800bdb:	ff d2                	call   *%edx
  800bdd:	89 c2                	mov    %eax,%edx
  800bdf:	83 c4 10             	add    $0x10,%esp
  800be2:	eb 09                	jmp    800bed <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800be4:	89 c2                	mov    %eax,%edx
  800be6:	eb 05                	jmp    800bed <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800be8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800bed:	89 d0                	mov    %edx,%eax
  800bef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 14             	sub    $0x14,%esp
  800bfb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bfe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c01:	50                   	push   %eax
  800c02:	ff 75 08             	pushl  0x8(%ebp)
  800c05:	e8 60 fb ff ff       	call   80076a <fd_lookup>
  800c0a:	83 c4 08             	add    $0x8,%esp
  800c0d:	89 c2                	mov    %eax,%edx
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	78 58                	js     800c6b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c13:	83 ec 08             	sub    $0x8,%esp
  800c16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c19:	50                   	push   %eax
  800c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c1d:	ff 30                	pushl  (%eax)
  800c1f:	e8 9c fb ff ff       	call   8007c0 <dev_lookup>
  800c24:	83 c4 10             	add    $0x10,%esp
  800c27:	85 c0                	test   %eax,%eax
  800c29:	78 37                	js     800c62 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c32:	74 32                	je     800c66 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c34:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c37:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c3e:	00 00 00 
	stat->st_isdir = 0;
  800c41:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c48:	00 00 00 
	stat->st_dev = dev;
  800c4b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c51:	83 ec 08             	sub    $0x8,%esp
  800c54:	53                   	push   %ebx
  800c55:	ff 75 f0             	pushl  -0x10(%ebp)
  800c58:	ff 50 14             	call   *0x14(%eax)
  800c5b:	89 c2                	mov    %eax,%edx
  800c5d:	83 c4 10             	add    $0x10,%esp
  800c60:	eb 09                	jmp    800c6b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c62:	89 c2                	mov    %eax,%edx
  800c64:	eb 05                	jmp    800c6b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c66:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c6b:	89 d0                	mov    %edx,%eax
  800c6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c70:	c9                   	leave  
  800c71:	c3                   	ret    

00800c72 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c77:	83 ec 08             	sub    $0x8,%esp
  800c7a:	6a 00                	push   $0x0
  800c7c:	ff 75 08             	pushl  0x8(%ebp)
  800c7f:	e8 e3 01 00 00       	call   800e67 <open>
  800c84:	89 c3                	mov    %eax,%ebx
  800c86:	83 c4 10             	add    $0x10,%esp
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	78 1b                	js     800ca8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c8d:	83 ec 08             	sub    $0x8,%esp
  800c90:	ff 75 0c             	pushl  0xc(%ebp)
  800c93:	50                   	push   %eax
  800c94:	e8 5b ff ff ff       	call   800bf4 <fstat>
  800c99:	89 c6                	mov    %eax,%esi
	close(fd);
  800c9b:	89 1c 24             	mov    %ebx,(%esp)
  800c9e:	e8 f4 fb ff ff       	call   800897 <close>
	return r;
  800ca3:	83 c4 10             	add    $0x10,%esp
  800ca6:	89 f0                	mov    %esi,%eax
}
  800ca8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	89 c6                	mov    %eax,%esi
  800cb6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800cb8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800cbf:	75 12                	jne    800cd3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	6a 01                	push   $0x1
  800cc6:	e8 39 12 00 00       	call   801f04 <ipc_find_env>
  800ccb:	a3 00 40 80 00       	mov    %eax,0x804000
  800cd0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800cd3:	6a 07                	push   $0x7
  800cd5:	68 00 50 80 00       	push   $0x805000
  800cda:	56                   	push   %esi
  800cdb:	ff 35 00 40 80 00    	pushl  0x804000
  800ce1:	e8 bc 11 00 00       	call   801ea2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ce6:	83 c4 0c             	add    $0xc,%esp
  800ce9:	6a 00                	push   $0x0
  800ceb:	53                   	push   %ebx
  800cec:	6a 00                	push   $0x0
  800cee:	e8 34 11 00 00       	call   801e27 <ipc_recv>
}
  800cf3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	8b 40 0c             	mov    0xc(%eax),%eax
  800d06:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d13:	ba 00 00 00 00       	mov    $0x0,%edx
  800d18:	b8 02 00 00 00       	mov    $0x2,%eax
  800d1d:	e8 8d ff ff ff       	call   800caf <fsipc>
}
  800d22:	c9                   	leave  
  800d23:	c3                   	ret    

00800d24 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2d:	8b 40 0c             	mov    0xc(%eax),%eax
  800d30:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d35:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3f:	e8 6b ff ff ff       	call   800caf <fsipc>
}
  800d44:	c9                   	leave  
  800d45:	c3                   	ret    

00800d46 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	53                   	push   %ebx
  800d4a:	83 ec 04             	sub    $0x4,%esp
  800d4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	8b 40 0c             	mov    0xc(%eax),%eax
  800d56:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d60:	b8 05 00 00 00       	mov    $0x5,%eax
  800d65:	e8 45 ff ff ff       	call   800caf <fsipc>
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	78 2c                	js     800d9a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d6e:	83 ec 08             	sub    $0x8,%esp
  800d71:	68 00 50 80 00       	push   $0x805000
  800d76:	53                   	push   %ebx
  800d77:	e8 d5 0c 00 00       	call   801a51 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d7c:	a1 80 50 80 00       	mov    0x805080,%eax
  800d81:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d87:	a1 84 50 80 00       	mov    0x805084,%eax
  800d8c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d9d:	c9                   	leave  
  800d9e:	c3                   	ret    

00800d9f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	83 ec 0c             	sub    $0xc,%esp
  800da5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	8b 52 0c             	mov    0xc(%edx),%edx
  800dae:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800db4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800db9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800dbe:	0f 47 c2             	cmova  %edx,%eax
  800dc1:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800dc6:	50                   	push   %eax
  800dc7:	ff 75 0c             	pushl  0xc(%ebp)
  800dca:	68 08 50 80 00       	push   $0x805008
  800dcf:	e8 0f 0e 00 00       	call   801be3 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800dd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd9:	b8 04 00 00 00       	mov    $0x4,%eax
  800dde:	e8 cc fe ff ff       	call   800caf <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800de3:	c9                   	leave  
  800de4:	c3                   	ret    

00800de5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
  800dea:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
  800df0:	8b 40 0c             	mov    0xc(%eax),%eax
  800df3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800df8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800dfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800e03:	b8 03 00 00 00       	mov    $0x3,%eax
  800e08:	e8 a2 fe ff ff       	call   800caf <fsipc>
  800e0d:	89 c3                	mov    %eax,%ebx
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	78 4b                	js     800e5e <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e13:	39 c6                	cmp    %eax,%esi
  800e15:	73 16                	jae    800e2d <devfile_read+0x48>
  800e17:	68 64 23 80 00       	push   $0x802364
  800e1c:	68 6b 23 80 00       	push   $0x80236b
  800e21:	6a 7c                	push   $0x7c
  800e23:	68 80 23 80 00       	push   $0x802380
  800e28:	e8 c6 05 00 00       	call   8013f3 <_panic>
	assert(r <= PGSIZE);
  800e2d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e32:	7e 16                	jle    800e4a <devfile_read+0x65>
  800e34:	68 8b 23 80 00       	push   $0x80238b
  800e39:	68 6b 23 80 00       	push   $0x80236b
  800e3e:	6a 7d                	push   $0x7d
  800e40:	68 80 23 80 00       	push   $0x802380
  800e45:	e8 a9 05 00 00       	call   8013f3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e4a:	83 ec 04             	sub    $0x4,%esp
  800e4d:	50                   	push   %eax
  800e4e:	68 00 50 80 00       	push   $0x805000
  800e53:	ff 75 0c             	pushl  0xc(%ebp)
  800e56:	e8 88 0d 00 00       	call   801be3 <memmove>
	return r;
  800e5b:	83 c4 10             	add    $0x10,%esp
}
  800e5e:	89 d8                	mov    %ebx,%eax
  800e60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	53                   	push   %ebx
  800e6b:	83 ec 20             	sub    $0x20,%esp
  800e6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e71:	53                   	push   %ebx
  800e72:	e8 a1 0b 00 00       	call   801a18 <strlen>
  800e77:	83 c4 10             	add    $0x10,%esp
  800e7a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e7f:	7f 67                	jg     800ee8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e81:	83 ec 0c             	sub    $0xc,%esp
  800e84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e87:	50                   	push   %eax
  800e88:	e8 8e f8 ff ff       	call   80071b <fd_alloc>
  800e8d:	83 c4 10             	add    $0x10,%esp
		return r;
  800e90:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e92:	85 c0                	test   %eax,%eax
  800e94:	78 57                	js     800eed <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e96:	83 ec 08             	sub    $0x8,%esp
  800e99:	53                   	push   %ebx
  800e9a:	68 00 50 80 00       	push   $0x805000
  800e9f:	e8 ad 0b 00 00       	call   801a51 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800eac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800eaf:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb4:	e8 f6 fd ff ff       	call   800caf <fsipc>
  800eb9:	89 c3                	mov    %eax,%ebx
  800ebb:	83 c4 10             	add    $0x10,%esp
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	79 14                	jns    800ed6 <open+0x6f>
		fd_close(fd, 0);
  800ec2:	83 ec 08             	sub    $0x8,%esp
  800ec5:	6a 00                	push   $0x0
  800ec7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eca:	e8 47 f9 ff ff       	call   800816 <fd_close>
		return r;
  800ecf:	83 c4 10             	add    $0x10,%esp
  800ed2:	89 da                	mov    %ebx,%edx
  800ed4:	eb 17                	jmp    800eed <open+0x86>
	}

	return fd2num(fd);
  800ed6:	83 ec 0c             	sub    $0xc,%esp
  800ed9:	ff 75 f4             	pushl  -0xc(%ebp)
  800edc:	e8 13 f8 ff ff       	call   8006f4 <fd2num>
  800ee1:	89 c2                	mov    %eax,%edx
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	eb 05                	jmp    800eed <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ee8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800eed:	89 d0                	mov    %edx,%eax
  800eef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    

00800ef4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800efa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eff:	b8 08 00 00 00       	mov    $0x8,%eax
  800f04:	e8 a6 fd ff ff       	call   800caf <fsipc>
}
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    

00800f0b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	56                   	push   %esi
  800f0f:	53                   	push   %ebx
  800f10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f13:	83 ec 0c             	sub    $0xc,%esp
  800f16:	ff 75 08             	pushl  0x8(%ebp)
  800f19:	e8 e6 f7 ff ff       	call   800704 <fd2data>
  800f1e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f20:	83 c4 08             	add    $0x8,%esp
  800f23:	68 97 23 80 00       	push   $0x802397
  800f28:	53                   	push   %ebx
  800f29:	e8 23 0b 00 00       	call   801a51 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f2e:	8b 46 04             	mov    0x4(%esi),%eax
  800f31:	2b 06                	sub    (%esi),%eax
  800f33:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f39:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f40:	00 00 00 
	stat->st_dev = &devpipe;
  800f43:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f4a:	30 80 00 
	return 0;
}
  800f4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	53                   	push   %ebx
  800f5d:	83 ec 0c             	sub    $0xc,%esp
  800f60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f63:	53                   	push   %ebx
  800f64:	6a 00                	push   $0x0
  800f66:	e8 a3 f2 ff ff       	call   80020e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f6b:	89 1c 24             	mov    %ebx,(%esp)
  800f6e:	e8 91 f7 ff ff       	call   800704 <fd2data>
  800f73:	83 c4 08             	add    $0x8,%esp
  800f76:	50                   	push   %eax
  800f77:	6a 00                	push   $0x0
  800f79:	e8 90 f2 ff ff       	call   80020e <sys_page_unmap>
}
  800f7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	57                   	push   %edi
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	83 ec 1c             	sub    $0x1c,%esp
  800f8c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f8f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f91:	a1 04 40 80 00       	mov    0x804004,%eax
  800f96:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	ff 75 e0             	pushl  -0x20(%ebp)
  800fa2:	e8 a2 0f 00 00       	call   801f49 <pageref>
  800fa7:	89 c3                	mov    %eax,%ebx
  800fa9:	89 3c 24             	mov    %edi,(%esp)
  800fac:	e8 98 0f 00 00       	call   801f49 <pageref>
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	39 c3                	cmp    %eax,%ebx
  800fb6:	0f 94 c1             	sete   %cl
  800fb9:	0f b6 c9             	movzbl %cl,%ecx
  800fbc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800fbf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fc5:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  800fcb:	39 ce                	cmp    %ecx,%esi
  800fcd:	74 1e                	je     800fed <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800fcf:	39 c3                	cmp    %eax,%ebx
  800fd1:	75 be                	jne    800f91 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800fd3:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  800fd9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fdc:	50                   	push   %eax
  800fdd:	56                   	push   %esi
  800fde:	68 9e 23 80 00       	push   $0x80239e
  800fe3:	e8 e4 04 00 00       	call   8014cc <cprintf>
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	eb a4                	jmp    800f91 <_pipeisclosed+0xe>
	}
}
  800fed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ff0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff3:	5b                   	pop    %ebx
  800ff4:	5e                   	pop    %esi
  800ff5:	5f                   	pop    %edi
  800ff6:	5d                   	pop    %ebp
  800ff7:	c3                   	ret    

00800ff8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	57                   	push   %edi
  800ffc:	56                   	push   %esi
  800ffd:	53                   	push   %ebx
  800ffe:	83 ec 28             	sub    $0x28,%esp
  801001:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801004:	56                   	push   %esi
  801005:	e8 fa f6 ff ff       	call   800704 <fd2data>
  80100a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	bf 00 00 00 00       	mov    $0x0,%edi
  801014:	eb 4b                	jmp    801061 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801016:	89 da                	mov    %ebx,%edx
  801018:	89 f0                	mov    %esi,%eax
  80101a:	e8 64 ff ff ff       	call   800f83 <_pipeisclosed>
  80101f:	85 c0                	test   %eax,%eax
  801021:	75 48                	jne    80106b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801023:	e8 42 f1 ff ff       	call   80016a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801028:	8b 43 04             	mov    0x4(%ebx),%eax
  80102b:	8b 0b                	mov    (%ebx),%ecx
  80102d:	8d 51 20             	lea    0x20(%ecx),%edx
  801030:	39 d0                	cmp    %edx,%eax
  801032:	73 e2                	jae    801016 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801034:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801037:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80103b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80103e:	89 c2                	mov    %eax,%edx
  801040:	c1 fa 1f             	sar    $0x1f,%edx
  801043:	89 d1                	mov    %edx,%ecx
  801045:	c1 e9 1b             	shr    $0x1b,%ecx
  801048:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80104b:	83 e2 1f             	and    $0x1f,%edx
  80104e:	29 ca                	sub    %ecx,%edx
  801050:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801054:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801058:	83 c0 01             	add    $0x1,%eax
  80105b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80105e:	83 c7 01             	add    $0x1,%edi
  801061:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801064:	75 c2                	jne    801028 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801066:	8b 45 10             	mov    0x10(%ebp),%eax
  801069:	eb 05                	jmp    801070 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80106b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801070:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801073:	5b                   	pop    %ebx
  801074:	5e                   	pop    %esi
  801075:	5f                   	pop    %edi
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    

00801078 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	57                   	push   %edi
  80107c:	56                   	push   %esi
  80107d:	53                   	push   %ebx
  80107e:	83 ec 18             	sub    $0x18,%esp
  801081:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801084:	57                   	push   %edi
  801085:	e8 7a f6 ff ff       	call   800704 <fd2data>
  80108a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80108c:	83 c4 10             	add    $0x10,%esp
  80108f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801094:	eb 3d                	jmp    8010d3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801096:	85 db                	test   %ebx,%ebx
  801098:	74 04                	je     80109e <devpipe_read+0x26>
				return i;
  80109a:	89 d8                	mov    %ebx,%eax
  80109c:	eb 44                	jmp    8010e2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80109e:	89 f2                	mov    %esi,%edx
  8010a0:	89 f8                	mov    %edi,%eax
  8010a2:	e8 dc fe ff ff       	call   800f83 <_pipeisclosed>
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	75 32                	jne    8010dd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8010ab:	e8 ba f0 ff ff       	call   80016a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8010b0:	8b 06                	mov    (%esi),%eax
  8010b2:	3b 46 04             	cmp    0x4(%esi),%eax
  8010b5:	74 df                	je     801096 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010b7:	99                   	cltd   
  8010b8:	c1 ea 1b             	shr    $0x1b,%edx
  8010bb:	01 d0                	add    %edx,%eax
  8010bd:	83 e0 1f             	and    $0x1f,%eax
  8010c0:	29 d0                	sub    %edx,%eax
  8010c2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8010c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ca:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8010cd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010d0:	83 c3 01             	add    $0x1,%ebx
  8010d3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010d6:	75 d8                	jne    8010b0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8010d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8010db:	eb 05                	jmp    8010e2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010dd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8010e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e5:	5b                   	pop    %ebx
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8010f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f5:	50                   	push   %eax
  8010f6:	e8 20 f6 ff ff       	call   80071b <fd_alloc>
  8010fb:	83 c4 10             	add    $0x10,%esp
  8010fe:	89 c2                	mov    %eax,%edx
  801100:	85 c0                	test   %eax,%eax
  801102:	0f 88 2c 01 00 00    	js     801234 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801108:	83 ec 04             	sub    $0x4,%esp
  80110b:	68 07 04 00 00       	push   $0x407
  801110:	ff 75 f4             	pushl  -0xc(%ebp)
  801113:	6a 00                	push   $0x0
  801115:	e8 6f f0 ff ff       	call   800189 <sys_page_alloc>
  80111a:	83 c4 10             	add    $0x10,%esp
  80111d:	89 c2                	mov    %eax,%edx
  80111f:	85 c0                	test   %eax,%eax
  801121:	0f 88 0d 01 00 00    	js     801234 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112d:	50                   	push   %eax
  80112e:	e8 e8 f5 ff ff       	call   80071b <fd_alloc>
  801133:	89 c3                	mov    %eax,%ebx
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	85 c0                	test   %eax,%eax
  80113a:	0f 88 e2 00 00 00    	js     801222 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801140:	83 ec 04             	sub    $0x4,%esp
  801143:	68 07 04 00 00       	push   $0x407
  801148:	ff 75 f0             	pushl  -0x10(%ebp)
  80114b:	6a 00                	push   $0x0
  80114d:	e8 37 f0 ff ff       	call   800189 <sys_page_alloc>
  801152:	89 c3                	mov    %eax,%ebx
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	0f 88 c3 00 00 00    	js     801222 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80115f:	83 ec 0c             	sub    $0xc,%esp
  801162:	ff 75 f4             	pushl  -0xc(%ebp)
  801165:	e8 9a f5 ff ff       	call   800704 <fd2data>
  80116a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80116c:	83 c4 0c             	add    $0xc,%esp
  80116f:	68 07 04 00 00       	push   $0x407
  801174:	50                   	push   %eax
  801175:	6a 00                	push   $0x0
  801177:	e8 0d f0 ff ff       	call   800189 <sys_page_alloc>
  80117c:	89 c3                	mov    %eax,%ebx
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	85 c0                	test   %eax,%eax
  801183:	0f 88 89 00 00 00    	js     801212 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801189:	83 ec 0c             	sub    $0xc,%esp
  80118c:	ff 75 f0             	pushl  -0x10(%ebp)
  80118f:	e8 70 f5 ff ff       	call   800704 <fd2data>
  801194:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80119b:	50                   	push   %eax
  80119c:	6a 00                	push   $0x0
  80119e:	56                   	push   %esi
  80119f:	6a 00                	push   $0x0
  8011a1:	e8 26 f0 ff ff       	call   8001cc <sys_page_map>
  8011a6:	89 c3                	mov    %eax,%ebx
  8011a8:	83 c4 20             	add    $0x20,%esp
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	78 55                	js     801204 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8011af:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8011ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011bd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8011c4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8011cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8011d9:	83 ec 0c             	sub    $0xc,%esp
  8011dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8011df:	e8 10 f5 ff ff       	call   8006f4 <fd2num>
  8011e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8011e9:	83 c4 04             	add    $0x4,%esp
  8011ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8011ef:	e8 00 f5 ff ff       	call   8006f4 <fd2num>
  8011f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f7:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801202:	eb 30                	jmp    801234 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801204:	83 ec 08             	sub    $0x8,%esp
  801207:	56                   	push   %esi
  801208:	6a 00                	push   $0x0
  80120a:	e8 ff ef ff ff       	call   80020e <sys_page_unmap>
  80120f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801212:	83 ec 08             	sub    $0x8,%esp
  801215:	ff 75 f0             	pushl  -0x10(%ebp)
  801218:	6a 00                	push   $0x0
  80121a:	e8 ef ef ff ff       	call   80020e <sys_page_unmap>
  80121f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801222:	83 ec 08             	sub    $0x8,%esp
  801225:	ff 75 f4             	pushl  -0xc(%ebp)
  801228:	6a 00                	push   $0x0
  80122a:	e8 df ef ff ff       	call   80020e <sys_page_unmap>
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801234:	89 d0                	mov    %edx,%eax
  801236:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801239:	5b                   	pop    %ebx
  80123a:	5e                   	pop    %esi
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    

0080123d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801243:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	ff 75 08             	pushl  0x8(%ebp)
  80124a:	e8 1b f5 ff ff       	call   80076a <fd_lookup>
  80124f:	83 c4 10             	add    $0x10,%esp
  801252:	85 c0                	test   %eax,%eax
  801254:	78 18                	js     80126e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801256:	83 ec 0c             	sub    $0xc,%esp
  801259:	ff 75 f4             	pushl  -0xc(%ebp)
  80125c:	e8 a3 f4 ff ff       	call   800704 <fd2data>
	return _pipeisclosed(fd, p);
  801261:	89 c2                	mov    %eax,%edx
  801263:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801266:	e8 18 fd ff ff       	call   800f83 <_pipeisclosed>
  80126b:	83 c4 10             	add    $0x10,%esp
}
  80126e:	c9                   	leave  
  80126f:	c3                   	ret    

00801270 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801273:	b8 00 00 00 00       	mov    $0x0,%eax
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801280:	68 b6 23 80 00       	push   $0x8023b6
  801285:	ff 75 0c             	pushl  0xc(%ebp)
  801288:	e8 c4 07 00 00       	call   801a51 <strcpy>
	return 0;
}
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
  801292:	c9                   	leave  
  801293:	c3                   	ret    

00801294 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	57                   	push   %edi
  801298:	56                   	push   %esi
  801299:	53                   	push   %ebx
  80129a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012a0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012a5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012ab:	eb 2d                	jmp    8012da <devcons_write+0x46>
		m = n - tot;
  8012ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012b0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8012b2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8012b5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8012ba:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012bd:	83 ec 04             	sub    $0x4,%esp
  8012c0:	53                   	push   %ebx
  8012c1:	03 45 0c             	add    0xc(%ebp),%eax
  8012c4:	50                   	push   %eax
  8012c5:	57                   	push   %edi
  8012c6:	e8 18 09 00 00       	call   801be3 <memmove>
		sys_cputs(buf, m);
  8012cb:	83 c4 08             	add    $0x8,%esp
  8012ce:	53                   	push   %ebx
  8012cf:	57                   	push   %edi
  8012d0:	e8 f8 ed ff ff       	call   8000cd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012d5:	01 de                	add    %ebx,%esi
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	89 f0                	mov    %esi,%eax
  8012dc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8012df:	72 cc                	jb     8012ad <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8012e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5f                   	pop    %edi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	83 ec 08             	sub    $0x8,%esp
  8012ef:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8012f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012f8:	74 2a                	je     801324 <devcons_read+0x3b>
  8012fa:	eb 05                	jmp    801301 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012fc:	e8 69 ee ff ff       	call   80016a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801301:	e8 e5 ed ff ff       	call   8000eb <sys_cgetc>
  801306:	85 c0                	test   %eax,%eax
  801308:	74 f2                	je     8012fc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80130a:	85 c0                	test   %eax,%eax
  80130c:	78 16                	js     801324 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80130e:	83 f8 04             	cmp    $0x4,%eax
  801311:	74 0c                	je     80131f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801313:	8b 55 0c             	mov    0xc(%ebp),%edx
  801316:	88 02                	mov    %al,(%edx)
	return 1;
  801318:	b8 01 00 00 00       	mov    $0x1,%eax
  80131d:	eb 05                	jmp    801324 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80131f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80132c:	8b 45 08             	mov    0x8(%ebp),%eax
  80132f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801332:	6a 01                	push   $0x1
  801334:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801337:	50                   	push   %eax
  801338:	e8 90 ed ff ff       	call   8000cd <sys_cputs>
}
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	c9                   	leave  
  801341:	c3                   	ret    

00801342 <getchar>:

int
getchar(void)
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801348:	6a 01                	push   $0x1
  80134a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	6a 00                	push   $0x0
  801350:	e8 7e f6 ff ff       	call   8009d3 <read>
	if (r < 0)
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	85 c0                	test   %eax,%eax
  80135a:	78 0f                	js     80136b <getchar+0x29>
		return r;
	if (r < 1)
  80135c:	85 c0                	test   %eax,%eax
  80135e:	7e 06                	jle    801366 <getchar+0x24>
		return -E_EOF;
	return c;
  801360:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801364:	eb 05                	jmp    80136b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801366:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80136b:	c9                   	leave  
  80136c:	c3                   	ret    

0080136d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801373:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801376:	50                   	push   %eax
  801377:	ff 75 08             	pushl  0x8(%ebp)
  80137a:	e8 eb f3 ff ff       	call   80076a <fd_lookup>
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	78 11                	js     801397 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801386:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801389:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80138f:	39 10                	cmp    %edx,(%eax)
  801391:	0f 94 c0             	sete   %al
  801394:	0f b6 c0             	movzbl %al,%eax
}
  801397:	c9                   	leave  
  801398:	c3                   	ret    

00801399 <opencons>:

int
opencons(void)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80139f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a2:	50                   	push   %eax
  8013a3:	e8 73 f3 ff ff       	call   80071b <fd_alloc>
  8013a8:	83 c4 10             	add    $0x10,%esp
		return r;
  8013ab:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	78 3e                	js     8013ef <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013b1:	83 ec 04             	sub    $0x4,%esp
  8013b4:	68 07 04 00 00       	push   $0x407
  8013b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8013bc:	6a 00                	push   $0x0
  8013be:	e8 c6 ed ff ff       	call   800189 <sys_page_alloc>
  8013c3:	83 c4 10             	add    $0x10,%esp
		return r;
  8013c6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 23                	js     8013ef <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8013cc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8013d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013da:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013e1:	83 ec 0c             	sub    $0xc,%esp
  8013e4:	50                   	push   %eax
  8013e5:	e8 0a f3 ff ff       	call   8006f4 <fd2num>
  8013ea:	89 c2                	mov    %eax,%edx
  8013ec:	83 c4 10             	add    $0x10,%esp
}
  8013ef:	89 d0                	mov    %edx,%eax
  8013f1:	c9                   	leave  
  8013f2:	c3                   	ret    

008013f3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	56                   	push   %esi
  8013f7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013f8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013fb:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801401:	e8 45 ed ff ff       	call   80014b <sys_getenvid>
  801406:	83 ec 0c             	sub    $0xc,%esp
  801409:	ff 75 0c             	pushl  0xc(%ebp)
  80140c:	ff 75 08             	pushl  0x8(%ebp)
  80140f:	56                   	push   %esi
  801410:	50                   	push   %eax
  801411:	68 c4 23 80 00       	push   $0x8023c4
  801416:	e8 b1 00 00 00       	call   8014cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80141b:	83 c4 18             	add    $0x18,%esp
  80141e:	53                   	push   %ebx
  80141f:	ff 75 10             	pushl  0x10(%ebp)
  801422:	e8 54 00 00 00       	call   80147b <vcprintf>
	cprintf("\n");
  801427:	c7 04 24 af 23 80 00 	movl   $0x8023af,(%esp)
  80142e:	e8 99 00 00 00       	call   8014cc <cprintf>
  801433:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801436:	cc                   	int3   
  801437:	eb fd                	jmp    801436 <_panic+0x43>

00801439 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	53                   	push   %ebx
  80143d:	83 ec 04             	sub    $0x4,%esp
  801440:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801443:	8b 13                	mov    (%ebx),%edx
  801445:	8d 42 01             	lea    0x1(%edx),%eax
  801448:	89 03                	mov    %eax,(%ebx)
  80144a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80144d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801451:	3d ff 00 00 00       	cmp    $0xff,%eax
  801456:	75 1a                	jne    801472 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801458:	83 ec 08             	sub    $0x8,%esp
  80145b:	68 ff 00 00 00       	push   $0xff
  801460:	8d 43 08             	lea    0x8(%ebx),%eax
  801463:	50                   	push   %eax
  801464:	e8 64 ec ff ff       	call   8000cd <sys_cputs>
		b->idx = 0;
  801469:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80146f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801472:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801476:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801479:	c9                   	leave  
  80147a:	c3                   	ret    

0080147b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801484:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80148b:	00 00 00 
	b.cnt = 0;
  80148e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801495:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801498:	ff 75 0c             	pushl  0xc(%ebp)
  80149b:	ff 75 08             	pushl  0x8(%ebp)
  80149e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8014a4:	50                   	push   %eax
  8014a5:	68 39 14 80 00       	push   $0x801439
  8014aa:	e8 54 01 00 00       	call   801603 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8014af:	83 c4 08             	add    $0x8,%esp
  8014b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8014b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014be:	50                   	push   %eax
  8014bf:	e8 09 ec ff ff       	call   8000cd <sys_cputs>

	return b.cnt;
}
  8014c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014ca:	c9                   	leave  
  8014cb:	c3                   	ret    

008014cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8014d5:	50                   	push   %eax
  8014d6:	ff 75 08             	pushl  0x8(%ebp)
  8014d9:	e8 9d ff ff ff       	call   80147b <vcprintf>
	va_end(ap);

	return cnt;
}
  8014de:	c9                   	leave  
  8014df:	c3                   	ret    

008014e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	57                   	push   %edi
  8014e4:	56                   	push   %esi
  8014e5:	53                   	push   %ebx
  8014e6:	83 ec 1c             	sub    $0x1c,%esp
  8014e9:	89 c7                	mov    %eax,%edi
  8014eb:	89 d6                	mov    %edx,%esi
  8014ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801501:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801504:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801507:	39 d3                	cmp    %edx,%ebx
  801509:	72 05                	jb     801510 <printnum+0x30>
  80150b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80150e:	77 45                	ja     801555 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801510:	83 ec 0c             	sub    $0xc,%esp
  801513:	ff 75 18             	pushl  0x18(%ebp)
  801516:	8b 45 14             	mov    0x14(%ebp),%eax
  801519:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80151c:	53                   	push   %ebx
  80151d:	ff 75 10             	pushl  0x10(%ebp)
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	ff 75 e4             	pushl  -0x1c(%ebp)
  801526:	ff 75 e0             	pushl  -0x20(%ebp)
  801529:	ff 75 dc             	pushl  -0x24(%ebp)
  80152c:	ff 75 d8             	pushl  -0x28(%ebp)
  80152f:	e8 5c 0a 00 00       	call   801f90 <__udivdi3>
  801534:	83 c4 18             	add    $0x18,%esp
  801537:	52                   	push   %edx
  801538:	50                   	push   %eax
  801539:	89 f2                	mov    %esi,%edx
  80153b:	89 f8                	mov    %edi,%eax
  80153d:	e8 9e ff ff ff       	call   8014e0 <printnum>
  801542:	83 c4 20             	add    $0x20,%esp
  801545:	eb 18                	jmp    80155f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801547:	83 ec 08             	sub    $0x8,%esp
  80154a:	56                   	push   %esi
  80154b:	ff 75 18             	pushl  0x18(%ebp)
  80154e:	ff d7                	call   *%edi
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	eb 03                	jmp    801558 <printnum+0x78>
  801555:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801558:	83 eb 01             	sub    $0x1,%ebx
  80155b:	85 db                	test   %ebx,%ebx
  80155d:	7f e8                	jg     801547 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	56                   	push   %esi
  801563:	83 ec 04             	sub    $0x4,%esp
  801566:	ff 75 e4             	pushl  -0x1c(%ebp)
  801569:	ff 75 e0             	pushl  -0x20(%ebp)
  80156c:	ff 75 dc             	pushl  -0x24(%ebp)
  80156f:	ff 75 d8             	pushl  -0x28(%ebp)
  801572:	e8 49 0b 00 00       	call   8020c0 <__umoddi3>
  801577:	83 c4 14             	add    $0x14,%esp
  80157a:	0f be 80 e7 23 80 00 	movsbl 0x8023e7(%eax),%eax
  801581:	50                   	push   %eax
  801582:	ff d7                	call   *%edi
}
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158a:	5b                   	pop    %ebx
  80158b:	5e                   	pop    %esi
  80158c:	5f                   	pop    %edi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    

0080158f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801592:	83 fa 01             	cmp    $0x1,%edx
  801595:	7e 0e                	jle    8015a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801597:	8b 10                	mov    (%eax),%edx
  801599:	8d 4a 08             	lea    0x8(%edx),%ecx
  80159c:	89 08                	mov    %ecx,(%eax)
  80159e:	8b 02                	mov    (%edx),%eax
  8015a0:	8b 52 04             	mov    0x4(%edx),%edx
  8015a3:	eb 22                	jmp    8015c7 <getuint+0x38>
	else if (lflag)
  8015a5:	85 d2                	test   %edx,%edx
  8015a7:	74 10                	je     8015b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8015a9:	8b 10                	mov    (%eax),%edx
  8015ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015ae:	89 08                	mov    %ecx,(%eax)
  8015b0:	8b 02                	mov    (%edx),%eax
  8015b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b7:	eb 0e                	jmp    8015c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8015b9:	8b 10                	mov    (%eax),%edx
  8015bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015be:	89 08                	mov    %ecx,(%eax)
  8015c0:	8b 02                	mov    (%edx),%eax
  8015c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    

008015c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8015d3:	8b 10                	mov    (%eax),%edx
  8015d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8015d8:	73 0a                	jae    8015e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8015da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8015dd:	89 08                	mov    %ecx,(%eax)
  8015df:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e2:	88 02                	mov    %al,(%edx)
}
  8015e4:	5d                   	pop    %ebp
  8015e5:	c3                   	ret    

008015e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8015ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015ef:	50                   	push   %eax
  8015f0:	ff 75 10             	pushl  0x10(%ebp)
  8015f3:	ff 75 0c             	pushl  0xc(%ebp)
  8015f6:	ff 75 08             	pushl  0x8(%ebp)
  8015f9:	e8 05 00 00 00       	call   801603 <vprintfmt>
	va_end(ap);
}
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	c9                   	leave  
  801602:	c3                   	ret    

00801603 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	57                   	push   %edi
  801607:	56                   	push   %esi
  801608:	53                   	push   %ebx
  801609:	83 ec 2c             	sub    $0x2c,%esp
  80160c:	8b 75 08             	mov    0x8(%ebp),%esi
  80160f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801612:	8b 7d 10             	mov    0x10(%ebp),%edi
  801615:	eb 12                	jmp    801629 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801617:	85 c0                	test   %eax,%eax
  801619:	0f 84 89 03 00 00    	je     8019a8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	53                   	push   %ebx
  801623:	50                   	push   %eax
  801624:	ff d6                	call   *%esi
  801626:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801629:	83 c7 01             	add    $0x1,%edi
  80162c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801630:	83 f8 25             	cmp    $0x25,%eax
  801633:	75 e2                	jne    801617 <vprintfmt+0x14>
  801635:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801639:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801640:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801647:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80164e:	ba 00 00 00 00       	mov    $0x0,%edx
  801653:	eb 07                	jmp    80165c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801655:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801658:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80165c:	8d 47 01             	lea    0x1(%edi),%eax
  80165f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801662:	0f b6 07             	movzbl (%edi),%eax
  801665:	0f b6 c8             	movzbl %al,%ecx
  801668:	83 e8 23             	sub    $0x23,%eax
  80166b:	3c 55                	cmp    $0x55,%al
  80166d:	0f 87 1a 03 00 00    	ja     80198d <vprintfmt+0x38a>
  801673:	0f b6 c0             	movzbl %al,%eax
  801676:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80167d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801680:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801684:	eb d6                	jmp    80165c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801689:	b8 00 00 00 00       	mov    $0x0,%eax
  80168e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801691:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801694:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801698:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80169b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80169e:	83 fa 09             	cmp    $0x9,%edx
  8016a1:	77 39                	ja     8016dc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8016a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8016a6:	eb e9                	jmp    801691 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8016a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ab:	8d 48 04             	lea    0x4(%eax),%ecx
  8016ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8016b1:	8b 00                	mov    (%eax),%eax
  8016b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8016b9:	eb 27                	jmp    8016e2 <vprintfmt+0xdf>
  8016bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016c5:	0f 49 c8             	cmovns %eax,%ecx
  8016c8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016ce:	eb 8c                	jmp    80165c <vprintfmt+0x59>
  8016d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8016d3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8016da:	eb 80                	jmp    80165c <vprintfmt+0x59>
  8016dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016df:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8016e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016e6:	0f 89 70 ff ff ff    	jns    80165c <vprintfmt+0x59>
				width = precision, precision = -1;
  8016ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8016ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016f2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016f9:	e9 5e ff ff ff       	jmp    80165c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016fe:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801701:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801704:	e9 53 ff ff ff       	jmp    80165c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801709:	8b 45 14             	mov    0x14(%ebp),%eax
  80170c:	8d 50 04             	lea    0x4(%eax),%edx
  80170f:	89 55 14             	mov    %edx,0x14(%ebp)
  801712:	83 ec 08             	sub    $0x8,%esp
  801715:	53                   	push   %ebx
  801716:	ff 30                	pushl  (%eax)
  801718:	ff d6                	call   *%esi
			break;
  80171a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80171d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801720:	e9 04 ff ff ff       	jmp    801629 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801725:	8b 45 14             	mov    0x14(%ebp),%eax
  801728:	8d 50 04             	lea    0x4(%eax),%edx
  80172b:	89 55 14             	mov    %edx,0x14(%ebp)
  80172e:	8b 00                	mov    (%eax),%eax
  801730:	99                   	cltd   
  801731:	31 d0                	xor    %edx,%eax
  801733:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801735:	83 f8 0f             	cmp    $0xf,%eax
  801738:	7f 0b                	jg     801745 <vprintfmt+0x142>
  80173a:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801741:	85 d2                	test   %edx,%edx
  801743:	75 18                	jne    80175d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801745:	50                   	push   %eax
  801746:	68 ff 23 80 00       	push   $0x8023ff
  80174b:	53                   	push   %ebx
  80174c:	56                   	push   %esi
  80174d:	e8 94 fe ff ff       	call   8015e6 <printfmt>
  801752:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801755:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801758:	e9 cc fe ff ff       	jmp    801629 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80175d:	52                   	push   %edx
  80175e:	68 7d 23 80 00       	push   $0x80237d
  801763:	53                   	push   %ebx
  801764:	56                   	push   %esi
  801765:	e8 7c fe ff ff       	call   8015e6 <printfmt>
  80176a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80176d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801770:	e9 b4 fe ff ff       	jmp    801629 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801775:	8b 45 14             	mov    0x14(%ebp),%eax
  801778:	8d 50 04             	lea    0x4(%eax),%edx
  80177b:	89 55 14             	mov    %edx,0x14(%ebp)
  80177e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801780:	85 ff                	test   %edi,%edi
  801782:	b8 f8 23 80 00       	mov    $0x8023f8,%eax
  801787:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80178a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80178e:	0f 8e 94 00 00 00    	jle    801828 <vprintfmt+0x225>
  801794:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801798:	0f 84 98 00 00 00    	je     801836 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80179e:	83 ec 08             	sub    $0x8,%esp
  8017a1:	ff 75 d0             	pushl  -0x30(%ebp)
  8017a4:	57                   	push   %edi
  8017a5:	e8 86 02 00 00       	call   801a30 <strnlen>
  8017aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8017ad:	29 c1                	sub    %eax,%ecx
  8017af:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8017b2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8017b5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8017b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017bc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017bf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017c1:	eb 0f                	jmp    8017d2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8017c3:	83 ec 08             	sub    $0x8,%esp
  8017c6:	53                   	push   %ebx
  8017c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8017ca:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017cc:	83 ef 01             	sub    $0x1,%edi
  8017cf:	83 c4 10             	add    $0x10,%esp
  8017d2:	85 ff                	test   %edi,%edi
  8017d4:	7f ed                	jg     8017c3 <vprintfmt+0x1c0>
  8017d6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017d9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8017dc:	85 c9                	test   %ecx,%ecx
  8017de:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e3:	0f 49 c1             	cmovns %ecx,%eax
  8017e6:	29 c1                	sub    %eax,%ecx
  8017e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8017eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017f1:	89 cb                	mov    %ecx,%ebx
  8017f3:	eb 4d                	jmp    801842 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017f9:	74 1b                	je     801816 <vprintfmt+0x213>
  8017fb:	0f be c0             	movsbl %al,%eax
  8017fe:	83 e8 20             	sub    $0x20,%eax
  801801:	83 f8 5e             	cmp    $0x5e,%eax
  801804:	76 10                	jbe    801816 <vprintfmt+0x213>
					putch('?', putdat);
  801806:	83 ec 08             	sub    $0x8,%esp
  801809:	ff 75 0c             	pushl  0xc(%ebp)
  80180c:	6a 3f                	push   $0x3f
  80180e:	ff 55 08             	call   *0x8(%ebp)
  801811:	83 c4 10             	add    $0x10,%esp
  801814:	eb 0d                	jmp    801823 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801816:	83 ec 08             	sub    $0x8,%esp
  801819:	ff 75 0c             	pushl  0xc(%ebp)
  80181c:	52                   	push   %edx
  80181d:	ff 55 08             	call   *0x8(%ebp)
  801820:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801823:	83 eb 01             	sub    $0x1,%ebx
  801826:	eb 1a                	jmp    801842 <vprintfmt+0x23f>
  801828:	89 75 08             	mov    %esi,0x8(%ebp)
  80182b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80182e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801831:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801834:	eb 0c                	jmp    801842 <vprintfmt+0x23f>
  801836:	89 75 08             	mov    %esi,0x8(%ebp)
  801839:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80183c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80183f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801842:	83 c7 01             	add    $0x1,%edi
  801845:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801849:	0f be d0             	movsbl %al,%edx
  80184c:	85 d2                	test   %edx,%edx
  80184e:	74 23                	je     801873 <vprintfmt+0x270>
  801850:	85 f6                	test   %esi,%esi
  801852:	78 a1                	js     8017f5 <vprintfmt+0x1f2>
  801854:	83 ee 01             	sub    $0x1,%esi
  801857:	79 9c                	jns    8017f5 <vprintfmt+0x1f2>
  801859:	89 df                	mov    %ebx,%edi
  80185b:	8b 75 08             	mov    0x8(%ebp),%esi
  80185e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801861:	eb 18                	jmp    80187b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801863:	83 ec 08             	sub    $0x8,%esp
  801866:	53                   	push   %ebx
  801867:	6a 20                	push   $0x20
  801869:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80186b:	83 ef 01             	sub    $0x1,%edi
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	eb 08                	jmp    80187b <vprintfmt+0x278>
  801873:	89 df                	mov    %ebx,%edi
  801875:	8b 75 08             	mov    0x8(%ebp),%esi
  801878:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80187b:	85 ff                	test   %edi,%edi
  80187d:	7f e4                	jg     801863 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80187f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801882:	e9 a2 fd ff ff       	jmp    801629 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801887:	83 fa 01             	cmp    $0x1,%edx
  80188a:	7e 16                	jle    8018a2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80188c:	8b 45 14             	mov    0x14(%ebp),%eax
  80188f:	8d 50 08             	lea    0x8(%eax),%edx
  801892:	89 55 14             	mov    %edx,0x14(%ebp)
  801895:	8b 50 04             	mov    0x4(%eax),%edx
  801898:	8b 00                	mov    (%eax),%eax
  80189a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80189d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8018a0:	eb 32                	jmp    8018d4 <vprintfmt+0x2d1>
	else if (lflag)
  8018a2:	85 d2                	test   %edx,%edx
  8018a4:	74 18                	je     8018be <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8018a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8018a9:	8d 50 04             	lea    0x4(%eax),%edx
  8018ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8018af:	8b 00                	mov    (%eax),%eax
  8018b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018b4:	89 c1                	mov    %eax,%ecx
  8018b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8018b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018bc:	eb 16                	jmp    8018d4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8018be:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c1:	8d 50 04             	lea    0x4(%eax),%edx
  8018c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8018c7:	8b 00                	mov    (%eax),%eax
  8018c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018cc:	89 c1                	mov    %eax,%ecx
  8018ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8018d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8018d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8018da:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8018df:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018e3:	79 74                	jns    801959 <vprintfmt+0x356>
				putch('-', putdat);
  8018e5:	83 ec 08             	sub    $0x8,%esp
  8018e8:	53                   	push   %ebx
  8018e9:	6a 2d                	push   $0x2d
  8018eb:	ff d6                	call   *%esi
				num = -(long long) num;
  8018ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8018f3:	f7 d8                	neg    %eax
  8018f5:	83 d2 00             	adc    $0x0,%edx
  8018f8:	f7 da                	neg    %edx
  8018fa:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801902:	eb 55                	jmp    801959 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801904:	8d 45 14             	lea    0x14(%ebp),%eax
  801907:	e8 83 fc ff ff       	call   80158f <getuint>
			base = 10;
  80190c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801911:	eb 46                	jmp    801959 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801913:	8d 45 14             	lea    0x14(%ebp),%eax
  801916:	e8 74 fc ff ff       	call   80158f <getuint>
			base = 8;
  80191b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801920:	eb 37                	jmp    801959 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801922:	83 ec 08             	sub    $0x8,%esp
  801925:	53                   	push   %ebx
  801926:	6a 30                	push   $0x30
  801928:	ff d6                	call   *%esi
			putch('x', putdat);
  80192a:	83 c4 08             	add    $0x8,%esp
  80192d:	53                   	push   %ebx
  80192e:	6a 78                	push   $0x78
  801930:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801932:	8b 45 14             	mov    0x14(%ebp),%eax
  801935:	8d 50 04             	lea    0x4(%eax),%edx
  801938:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80193b:	8b 00                	mov    (%eax),%eax
  80193d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801942:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801945:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80194a:	eb 0d                	jmp    801959 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80194c:	8d 45 14             	lea    0x14(%ebp),%eax
  80194f:	e8 3b fc ff ff       	call   80158f <getuint>
			base = 16;
  801954:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801959:	83 ec 0c             	sub    $0xc,%esp
  80195c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801960:	57                   	push   %edi
  801961:	ff 75 e0             	pushl  -0x20(%ebp)
  801964:	51                   	push   %ecx
  801965:	52                   	push   %edx
  801966:	50                   	push   %eax
  801967:	89 da                	mov    %ebx,%edx
  801969:	89 f0                	mov    %esi,%eax
  80196b:	e8 70 fb ff ff       	call   8014e0 <printnum>
			break;
  801970:	83 c4 20             	add    $0x20,%esp
  801973:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801976:	e9 ae fc ff ff       	jmp    801629 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	53                   	push   %ebx
  80197f:	51                   	push   %ecx
  801980:	ff d6                	call   *%esi
			break;
  801982:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801985:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801988:	e9 9c fc ff ff       	jmp    801629 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80198d:	83 ec 08             	sub    $0x8,%esp
  801990:	53                   	push   %ebx
  801991:	6a 25                	push   $0x25
  801993:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	eb 03                	jmp    80199d <vprintfmt+0x39a>
  80199a:	83 ef 01             	sub    $0x1,%edi
  80199d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8019a1:	75 f7                	jne    80199a <vprintfmt+0x397>
  8019a3:	e9 81 fc ff ff       	jmp    801629 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8019a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ab:	5b                   	pop    %ebx
  8019ac:	5e                   	pop    %esi
  8019ad:	5f                   	pop    %edi
  8019ae:	5d                   	pop    %ebp
  8019af:	c3                   	ret    

008019b0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	83 ec 18             	sub    $0x18,%esp
  8019b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019bf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8019c3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8019c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	74 26                	je     8019f7 <vsnprintf+0x47>
  8019d1:	85 d2                	test   %edx,%edx
  8019d3:	7e 22                	jle    8019f7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8019d5:	ff 75 14             	pushl  0x14(%ebp)
  8019d8:	ff 75 10             	pushl  0x10(%ebp)
  8019db:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019de:	50                   	push   %eax
  8019df:	68 c9 15 80 00       	push   $0x8015c9
  8019e4:	e8 1a fc ff ff       	call   801603 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019ec:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	eb 05                	jmp    8019fc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019fc:	c9                   	leave  
  8019fd:	c3                   	ret    

008019fe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a04:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a07:	50                   	push   %eax
  801a08:	ff 75 10             	pushl  0x10(%ebp)
  801a0b:	ff 75 0c             	pushl  0xc(%ebp)
  801a0e:	ff 75 08             	pushl  0x8(%ebp)
  801a11:	e8 9a ff ff ff       	call   8019b0 <vsnprintf>
	va_end(ap);

	return rc;
}
  801a16:	c9                   	leave  
  801a17:	c3                   	ret    

00801a18 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801a1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a23:	eb 03                	jmp    801a28 <strlen+0x10>
		n++;
  801a25:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a28:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a2c:	75 f7                	jne    801a25 <strlen+0xd>
		n++;
	return n;
}
  801a2e:	5d                   	pop    %ebp
  801a2f:	c3                   	ret    

00801a30 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a36:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a39:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3e:	eb 03                	jmp    801a43 <strnlen+0x13>
		n++;
  801a40:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a43:	39 c2                	cmp    %eax,%edx
  801a45:	74 08                	je     801a4f <strnlen+0x1f>
  801a47:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801a4b:	75 f3                	jne    801a40 <strnlen+0x10>
  801a4d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a4f:	5d                   	pop    %ebp
  801a50:	c3                   	ret    

00801a51 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	53                   	push   %ebx
  801a55:	8b 45 08             	mov    0x8(%ebp),%eax
  801a58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a5b:	89 c2                	mov    %eax,%edx
  801a5d:	83 c2 01             	add    $0x1,%edx
  801a60:	83 c1 01             	add    $0x1,%ecx
  801a63:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a67:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a6a:	84 db                	test   %bl,%bl
  801a6c:	75 ef                	jne    801a5d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a6e:	5b                   	pop    %ebx
  801a6f:	5d                   	pop    %ebp
  801a70:	c3                   	ret    

00801a71 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	53                   	push   %ebx
  801a75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a78:	53                   	push   %ebx
  801a79:	e8 9a ff ff ff       	call   801a18 <strlen>
  801a7e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a81:	ff 75 0c             	pushl  0xc(%ebp)
  801a84:	01 d8                	add    %ebx,%eax
  801a86:	50                   	push   %eax
  801a87:	e8 c5 ff ff ff       	call   801a51 <strcpy>
	return dst;
}
  801a8c:	89 d8                	mov    %ebx,%eax
  801a8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a91:	c9                   	leave  
  801a92:	c3                   	ret    

00801a93 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	56                   	push   %esi
  801a97:	53                   	push   %ebx
  801a98:	8b 75 08             	mov    0x8(%ebp),%esi
  801a9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9e:	89 f3                	mov    %esi,%ebx
  801aa0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801aa3:	89 f2                	mov    %esi,%edx
  801aa5:	eb 0f                	jmp    801ab6 <strncpy+0x23>
		*dst++ = *src;
  801aa7:	83 c2 01             	add    $0x1,%edx
  801aaa:	0f b6 01             	movzbl (%ecx),%eax
  801aad:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ab0:	80 39 01             	cmpb   $0x1,(%ecx)
  801ab3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ab6:	39 da                	cmp    %ebx,%edx
  801ab8:	75 ed                	jne    801aa7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801aba:	89 f0                	mov    %esi,%eax
  801abc:	5b                   	pop    %ebx
  801abd:	5e                   	pop    %esi
  801abe:	5d                   	pop    %ebp
  801abf:	c3                   	ret    

00801ac0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	56                   	push   %esi
  801ac4:	53                   	push   %ebx
  801ac5:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801acb:	8b 55 10             	mov    0x10(%ebp),%edx
  801ace:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ad0:	85 d2                	test   %edx,%edx
  801ad2:	74 21                	je     801af5 <strlcpy+0x35>
  801ad4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801ad8:	89 f2                	mov    %esi,%edx
  801ada:	eb 09                	jmp    801ae5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801adc:	83 c2 01             	add    $0x1,%edx
  801adf:	83 c1 01             	add    $0x1,%ecx
  801ae2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ae5:	39 c2                	cmp    %eax,%edx
  801ae7:	74 09                	je     801af2 <strlcpy+0x32>
  801ae9:	0f b6 19             	movzbl (%ecx),%ebx
  801aec:	84 db                	test   %bl,%bl
  801aee:	75 ec                	jne    801adc <strlcpy+0x1c>
  801af0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801af2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801af5:	29 f0                	sub    %esi,%eax
}
  801af7:	5b                   	pop    %ebx
  801af8:	5e                   	pop    %esi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b01:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801b04:	eb 06                	jmp    801b0c <strcmp+0x11>
		p++, q++;
  801b06:	83 c1 01             	add    $0x1,%ecx
  801b09:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801b0c:	0f b6 01             	movzbl (%ecx),%eax
  801b0f:	84 c0                	test   %al,%al
  801b11:	74 04                	je     801b17 <strcmp+0x1c>
  801b13:	3a 02                	cmp    (%edx),%al
  801b15:	74 ef                	je     801b06 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801b17:	0f b6 c0             	movzbl %al,%eax
  801b1a:	0f b6 12             	movzbl (%edx),%edx
  801b1d:	29 d0                	sub    %edx,%eax
}
  801b1f:	5d                   	pop    %ebp
  801b20:	c3                   	ret    

00801b21 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	53                   	push   %ebx
  801b25:	8b 45 08             	mov    0x8(%ebp),%eax
  801b28:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b2b:	89 c3                	mov    %eax,%ebx
  801b2d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801b30:	eb 06                	jmp    801b38 <strncmp+0x17>
		n--, p++, q++;
  801b32:	83 c0 01             	add    $0x1,%eax
  801b35:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b38:	39 d8                	cmp    %ebx,%eax
  801b3a:	74 15                	je     801b51 <strncmp+0x30>
  801b3c:	0f b6 08             	movzbl (%eax),%ecx
  801b3f:	84 c9                	test   %cl,%cl
  801b41:	74 04                	je     801b47 <strncmp+0x26>
  801b43:	3a 0a                	cmp    (%edx),%cl
  801b45:	74 eb                	je     801b32 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b47:	0f b6 00             	movzbl (%eax),%eax
  801b4a:	0f b6 12             	movzbl (%edx),%edx
  801b4d:	29 d0                	sub    %edx,%eax
  801b4f:	eb 05                	jmp    801b56 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b51:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b56:	5b                   	pop    %ebx
  801b57:	5d                   	pop    %ebp
  801b58:	c3                   	ret    

00801b59 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b63:	eb 07                	jmp    801b6c <strchr+0x13>
		if (*s == c)
  801b65:	38 ca                	cmp    %cl,%dl
  801b67:	74 0f                	je     801b78 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b69:	83 c0 01             	add    $0x1,%eax
  801b6c:	0f b6 10             	movzbl (%eax),%edx
  801b6f:	84 d2                	test   %dl,%dl
  801b71:	75 f2                	jne    801b65 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b84:	eb 03                	jmp    801b89 <strfind+0xf>
  801b86:	83 c0 01             	add    $0x1,%eax
  801b89:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b8c:	38 ca                	cmp    %cl,%dl
  801b8e:	74 04                	je     801b94 <strfind+0x1a>
  801b90:	84 d2                	test   %dl,%dl
  801b92:	75 f2                	jne    801b86 <strfind+0xc>
			break;
	return (char *) s;
}
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	57                   	push   %edi
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ba2:	85 c9                	test   %ecx,%ecx
  801ba4:	74 36                	je     801bdc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ba6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801bac:	75 28                	jne    801bd6 <memset+0x40>
  801bae:	f6 c1 03             	test   $0x3,%cl
  801bb1:	75 23                	jne    801bd6 <memset+0x40>
		c &= 0xFF;
  801bb3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801bb7:	89 d3                	mov    %edx,%ebx
  801bb9:	c1 e3 08             	shl    $0x8,%ebx
  801bbc:	89 d6                	mov    %edx,%esi
  801bbe:	c1 e6 18             	shl    $0x18,%esi
  801bc1:	89 d0                	mov    %edx,%eax
  801bc3:	c1 e0 10             	shl    $0x10,%eax
  801bc6:	09 f0                	or     %esi,%eax
  801bc8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801bca:	89 d8                	mov    %ebx,%eax
  801bcc:	09 d0                	or     %edx,%eax
  801bce:	c1 e9 02             	shr    $0x2,%ecx
  801bd1:	fc                   	cld    
  801bd2:	f3 ab                	rep stos %eax,%es:(%edi)
  801bd4:	eb 06                	jmp    801bdc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd9:	fc                   	cld    
  801bda:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801bdc:	89 f8                	mov    %edi,%eax
  801bde:	5b                   	pop    %ebx
  801bdf:	5e                   	pop    %esi
  801be0:	5f                   	pop    %edi
  801be1:	5d                   	pop    %ebp
  801be2:	c3                   	ret    

00801be3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	57                   	push   %edi
  801be7:	56                   	push   %esi
  801be8:	8b 45 08             	mov    0x8(%ebp),%eax
  801beb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801bf1:	39 c6                	cmp    %eax,%esi
  801bf3:	73 35                	jae    801c2a <memmove+0x47>
  801bf5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801bf8:	39 d0                	cmp    %edx,%eax
  801bfa:	73 2e                	jae    801c2a <memmove+0x47>
		s += n;
		d += n;
  801bfc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bff:	89 d6                	mov    %edx,%esi
  801c01:	09 fe                	or     %edi,%esi
  801c03:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801c09:	75 13                	jne    801c1e <memmove+0x3b>
  801c0b:	f6 c1 03             	test   $0x3,%cl
  801c0e:	75 0e                	jne    801c1e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801c10:	83 ef 04             	sub    $0x4,%edi
  801c13:	8d 72 fc             	lea    -0x4(%edx),%esi
  801c16:	c1 e9 02             	shr    $0x2,%ecx
  801c19:	fd                   	std    
  801c1a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c1c:	eb 09                	jmp    801c27 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801c1e:	83 ef 01             	sub    $0x1,%edi
  801c21:	8d 72 ff             	lea    -0x1(%edx),%esi
  801c24:	fd                   	std    
  801c25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801c27:	fc                   	cld    
  801c28:	eb 1d                	jmp    801c47 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c2a:	89 f2                	mov    %esi,%edx
  801c2c:	09 c2                	or     %eax,%edx
  801c2e:	f6 c2 03             	test   $0x3,%dl
  801c31:	75 0f                	jne    801c42 <memmove+0x5f>
  801c33:	f6 c1 03             	test   $0x3,%cl
  801c36:	75 0a                	jne    801c42 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801c38:	c1 e9 02             	shr    $0x2,%ecx
  801c3b:	89 c7                	mov    %eax,%edi
  801c3d:	fc                   	cld    
  801c3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c40:	eb 05                	jmp    801c47 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c42:	89 c7                	mov    %eax,%edi
  801c44:	fc                   	cld    
  801c45:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c47:	5e                   	pop    %esi
  801c48:	5f                   	pop    %edi
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    

00801c4b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c4e:	ff 75 10             	pushl  0x10(%ebp)
  801c51:	ff 75 0c             	pushl  0xc(%ebp)
  801c54:	ff 75 08             	pushl  0x8(%ebp)
  801c57:	e8 87 ff ff ff       	call   801be3 <memmove>
}
  801c5c:	c9                   	leave  
  801c5d:	c3                   	ret    

00801c5e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	56                   	push   %esi
  801c62:	53                   	push   %ebx
  801c63:	8b 45 08             	mov    0x8(%ebp),%eax
  801c66:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c69:	89 c6                	mov    %eax,%esi
  801c6b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c6e:	eb 1a                	jmp    801c8a <memcmp+0x2c>
		if (*s1 != *s2)
  801c70:	0f b6 08             	movzbl (%eax),%ecx
  801c73:	0f b6 1a             	movzbl (%edx),%ebx
  801c76:	38 d9                	cmp    %bl,%cl
  801c78:	74 0a                	je     801c84 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c7a:	0f b6 c1             	movzbl %cl,%eax
  801c7d:	0f b6 db             	movzbl %bl,%ebx
  801c80:	29 d8                	sub    %ebx,%eax
  801c82:	eb 0f                	jmp    801c93 <memcmp+0x35>
		s1++, s2++;
  801c84:	83 c0 01             	add    $0x1,%eax
  801c87:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c8a:	39 f0                	cmp    %esi,%eax
  801c8c:	75 e2                	jne    801c70 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	53                   	push   %ebx
  801c9b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c9e:	89 c1                	mov    %eax,%ecx
  801ca0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801ca3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ca7:	eb 0a                	jmp    801cb3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ca9:	0f b6 10             	movzbl (%eax),%edx
  801cac:	39 da                	cmp    %ebx,%edx
  801cae:	74 07                	je     801cb7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801cb0:	83 c0 01             	add    $0x1,%eax
  801cb3:	39 c8                	cmp    %ecx,%eax
  801cb5:	72 f2                	jb     801ca9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801cb7:	5b                   	pop    %ebx
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    

00801cba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	57                   	push   %edi
  801cbe:	56                   	push   %esi
  801cbf:	53                   	push   %ebx
  801cc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cc6:	eb 03                	jmp    801ccb <strtol+0x11>
		s++;
  801cc8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ccb:	0f b6 01             	movzbl (%ecx),%eax
  801cce:	3c 20                	cmp    $0x20,%al
  801cd0:	74 f6                	je     801cc8 <strtol+0xe>
  801cd2:	3c 09                	cmp    $0x9,%al
  801cd4:	74 f2                	je     801cc8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801cd6:	3c 2b                	cmp    $0x2b,%al
  801cd8:	75 0a                	jne    801ce4 <strtol+0x2a>
		s++;
  801cda:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801cdd:	bf 00 00 00 00       	mov    $0x0,%edi
  801ce2:	eb 11                	jmp    801cf5 <strtol+0x3b>
  801ce4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ce9:	3c 2d                	cmp    $0x2d,%al
  801ceb:	75 08                	jne    801cf5 <strtol+0x3b>
		s++, neg = 1;
  801ced:	83 c1 01             	add    $0x1,%ecx
  801cf0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801cf5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801cfb:	75 15                	jne    801d12 <strtol+0x58>
  801cfd:	80 39 30             	cmpb   $0x30,(%ecx)
  801d00:	75 10                	jne    801d12 <strtol+0x58>
  801d02:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801d06:	75 7c                	jne    801d84 <strtol+0xca>
		s += 2, base = 16;
  801d08:	83 c1 02             	add    $0x2,%ecx
  801d0b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801d10:	eb 16                	jmp    801d28 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801d12:	85 db                	test   %ebx,%ebx
  801d14:	75 12                	jne    801d28 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801d16:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d1b:	80 39 30             	cmpb   $0x30,(%ecx)
  801d1e:	75 08                	jne    801d28 <strtol+0x6e>
		s++, base = 8;
  801d20:	83 c1 01             	add    $0x1,%ecx
  801d23:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801d28:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801d30:	0f b6 11             	movzbl (%ecx),%edx
  801d33:	8d 72 d0             	lea    -0x30(%edx),%esi
  801d36:	89 f3                	mov    %esi,%ebx
  801d38:	80 fb 09             	cmp    $0x9,%bl
  801d3b:	77 08                	ja     801d45 <strtol+0x8b>
			dig = *s - '0';
  801d3d:	0f be d2             	movsbl %dl,%edx
  801d40:	83 ea 30             	sub    $0x30,%edx
  801d43:	eb 22                	jmp    801d67 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801d45:	8d 72 9f             	lea    -0x61(%edx),%esi
  801d48:	89 f3                	mov    %esi,%ebx
  801d4a:	80 fb 19             	cmp    $0x19,%bl
  801d4d:	77 08                	ja     801d57 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d4f:	0f be d2             	movsbl %dl,%edx
  801d52:	83 ea 57             	sub    $0x57,%edx
  801d55:	eb 10                	jmp    801d67 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d57:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d5a:	89 f3                	mov    %esi,%ebx
  801d5c:	80 fb 19             	cmp    $0x19,%bl
  801d5f:	77 16                	ja     801d77 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d61:	0f be d2             	movsbl %dl,%edx
  801d64:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d67:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d6a:	7d 0b                	jge    801d77 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d6c:	83 c1 01             	add    $0x1,%ecx
  801d6f:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d73:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d75:	eb b9                	jmp    801d30 <strtol+0x76>

	if (endptr)
  801d77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d7b:	74 0d                	je     801d8a <strtol+0xd0>
		*endptr = (char *) s;
  801d7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d80:	89 0e                	mov    %ecx,(%esi)
  801d82:	eb 06                	jmp    801d8a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d84:	85 db                	test   %ebx,%ebx
  801d86:	74 98                	je     801d20 <strtol+0x66>
  801d88:	eb 9e                	jmp    801d28 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d8a:	89 c2                	mov    %eax,%edx
  801d8c:	f7 da                	neg    %edx
  801d8e:	85 ff                	test   %edi,%edi
  801d90:	0f 45 c2             	cmovne %edx,%eax
}
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5f                   	pop    %edi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    

00801d98 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d9e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801da5:	75 2a                	jne    801dd1 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801da7:	83 ec 04             	sub    $0x4,%esp
  801daa:	6a 07                	push   $0x7
  801dac:	68 00 f0 bf ee       	push   $0xeebff000
  801db1:	6a 00                	push   $0x0
  801db3:	e8 d1 e3 ff ff       	call   800189 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	79 12                	jns    801dd1 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801dbf:	50                   	push   %eax
  801dc0:	68 e0 26 80 00       	push   $0x8026e0
  801dc5:	6a 23                	push   $0x23
  801dc7:	68 e4 26 80 00       	push   $0x8026e4
  801dcc:	e8 22 f6 ff ff       	call   8013f3 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd4:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801dd9:	83 ec 08             	sub    $0x8,%esp
  801ddc:	68 03 1e 80 00       	push   $0x801e03
  801de1:	6a 00                	push   $0x0
  801de3:	e8 ec e4 ff ff       	call   8002d4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	85 c0                	test   %eax,%eax
  801ded:	79 12                	jns    801e01 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801def:	50                   	push   %eax
  801df0:	68 e0 26 80 00       	push   $0x8026e0
  801df5:	6a 2c                	push   $0x2c
  801df7:	68 e4 26 80 00       	push   $0x8026e4
  801dfc:	e8 f2 f5 ff ff       	call   8013f3 <_panic>
	}
}
  801e01:	c9                   	leave  
  801e02:	c3                   	ret    

00801e03 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e03:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e04:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e09:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e0b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e0e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e12:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e17:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e1b:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e1d:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e20:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e21:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e24:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e25:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e26:	c3                   	ret    

00801e27 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	56                   	push   %esi
  801e2b:	53                   	push   %ebx
  801e2c:	8b 75 08             	mov    0x8(%ebp),%esi
  801e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e35:	85 c0                	test   %eax,%eax
  801e37:	75 12                	jne    801e4b <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e39:	83 ec 0c             	sub    $0xc,%esp
  801e3c:	68 00 00 c0 ee       	push   $0xeec00000
  801e41:	e8 f3 e4 ff ff       	call   800339 <sys_ipc_recv>
  801e46:	83 c4 10             	add    $0x10,%esp
  801e49:	eb 0c                	jmp    801e57 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e4b:	83 ec 0c             	sub    $0xc,%esp
  801e4e:	50                   	push   %eax
  801e4f:	e8 e5 e4 ff ff       	call   800339 <sys_ipc_recv>
  801e54:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e57:	85 f6                	test   %esi,%esi
  801e59:	0f 95 c1             	setne  %cl
  801e5c:	85 db                	test   %ebx,%ebx
  801e5e:	0f 95 c2             	setne  %dl
  801e61:	84 d1                	test   %dl,%cl
  801e63:	74 09                	je     801e6e <ipc_recv+0x47>
  801e65:	89 c2                	mov    %eax,%edx
  801e67:	c1 ea 1f             	shr    $0x1f,%edx
  801e6a:	84 d2                	test   %dl,%dl
  801e6c:	75 2d                	jne    801e9b <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e6e:	85 f6                	test   %esi,%esi
  801e70:	74 0d                	je     801e7f <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e72:	a1 04 40 80 00       	mov    0x804004,%eax
  801e77:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801e7d:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e7f:	85 db                	test   %ebx,%ebx
  801e81:	74 0d                	je     801e90 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e83:	a1 04 40 80 00       	mov    0x804004,%eax
  801e88:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801e8e:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e90:	a1 04 40 80 00       	mov    0x804004,%eax
  801e95:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801e9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e9e:	5b                   	pop    %ebx
  801e9f:	5e                   	pop    %esi
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    

00801ea2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	57                   	push   %edi
  801ea6:	56                   	push   %esi
  801ea7:	53                   	push   %ebx
  801ea8:	83 ec 0c             	sub    $0xc,%esp
  801eab:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eae:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801eb4:	85 db                	test   %ebx,%ebx
  801eb6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ebb:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ebe:	ff 75 14             	pushl  0x14(%ebp)
  801ec1:	53                   	push   %ebx
  801ec2:	56                   	push   %esi
  801ec3:	57                   	push   %edi
  801ec4:	e8 4d e4 ff ff       	call   800316 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ec9:	89 c2                	mov    %eax,%edx
  801ecb:	c1 ea 1f             	shr    $0x1f,%edx
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	84 d2                	test   %dl,%dl
  801ed3:	74 17                	je     801eec <ipc_send+0x4a>
  801ed5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ed8:	74 12                	je     801eec <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801eda:	50                   	push   %eax
  801edb:	68 f2 26 80 00       	push   $0x8026f2
  801ee0:	6a 47                	push   $0x47
  801ee2:	68 00 27 80 00       	push   $0x802700
  801ee7:	e8 07 f5 ff ff       	call   8013f3 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801eec:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eef:	75 07                	jne    801ef8 <ipc_send+0x56>
			sys_yield();
  801ef1:	e8 74 e2 ff ff       	call   80016a <sys_yield>
  801ef6:	eb c6                	jmp    801ebe <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ef8:	85 c0                	test   %eax,%eax
  801efa:	75 c2                	jne    801ebe <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801efc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eff:	5b                   	pop    %ebx
  801f00:	5e                   	pop    %esi
  801f01:	5f                   	pop    %edi
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    

00801f04 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f04:	55                   	push   %ebp
  801f05:	89 e5                	mov    %esp,%ebp
  801f07:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f0a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f0f:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801f15:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f1b:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801f21:	39 ca                	cmp    %ecx,%edx
  801f23:	75 13                	jne    801f38 <ipc_find_env+0x34>
			return envs[i].env_id;
  801f25:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801f2b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f30:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801f36:	eb 0f                	jmp    801f47 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f38:	83 c0 01             	add    $0x1,%eax
  801f3b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f40:	75 cd                	jne    801f0f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f47:	5d                   	pop    %ebp
  801f48:	c3                   	ret    

00801f49 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f4f:	89 d0                	mov    %edx,%eax
  801f51:	c1 e8 16             	shr    $0x16,%eax
  801f54:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f5b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f60:	f6 c1 01             	test   $0x1,%cl
  801f63:	74 1d                	je     801f82 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f65:	c1 ea 0c             	shr    $0xc,%edx
  801f68:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f6f:	f6 c2 01             	test   $0x1,%dl
  801f72:	74 0e                	je     801f82 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f74:	c1 ea 0c             	shr    $0xc,%edx
  801f77:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f7e:	ef 
  801f7f:	0f b7 c0             	movzwl %ax,%eax
}
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    
  801f84:	66 90                	xchg   %ax,%ax
  801f86:	66 90                	xchg   %ax,%ax
  801f88:	66 90                	xchg   %ax,%ax
  801f8a:	66 90                	xchg   %ax,%ax
  801f8c:	66 90                	xchg   %ax,%ax
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
