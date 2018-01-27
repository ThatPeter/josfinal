
obj/user/evilhello.debug:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 88 00 00 00       	call   8000cd <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

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
  80005f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  8000b9:	e8 bb 07 00 00       	call   800879 <close_all>
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
  800132:	68 ca 21 80 00       	push   $0x8021ca
  800137:	6a 23                	push   $0x23
  800139:	68 e7 21 80 00       	push   $0x8021e7
  80013e:	e8 5e 12 00 00       	call   8013a1 <_panic>

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
  8001b3:	68 ca 21 80 00       	push   $0x8021ca
  8001b8:	6a 23                	push   $0x23
  8001ba:	68 e7 21 80 00       	push   $0x8021e7
  8001bf:	e8 dd 11 00 00       	call   8013a1 <_panic>

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
  8001f5:	68 ca 21 80 00       	push   $0x8021ca
  8001fa:	6a 23                	push   $0x23
  8001fc:	68 e7 21 80 00       	push   $0x8021e7
  800201:	e8 9b 11 00 00       	call   8013a1 <_panic>

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
  800237:	68 ca 21 80 00       	push   $0x8021ca
  80023c:	6a 23                	push   $0x23
  80023e:	68 e7 21 80 00       	push   $0x8021e7
  800243:	e8 59 11 00 00       	call   8013a1 <_panic>

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
  800279:	68 ca 21 80 00       	push   $0x8021ca
  80027e:	6a 23                	push   $0x23
  800280:	68 e7 21 80 00       	push   $0x8021e7
  800285:	e8 17 11 00 00       	call   8013a1 <_panic>

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
  8002bb:	68 ca 21 80 00       	push   $0x8021ca
  8002c0:	6a 23                	push   $0x23
  8002c2:	68 e7 21 80 00       	push   $0x8021e7
  8002c7:	e8 d5 10 00 00       	call   8013a1 <_panic>
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
  8002fd:	68 ca 21 80 00       	push   $0x8021ca
  800302:	6a 23                	push   $0x23
  800304:	68 e7 21 80 00       	push   $0x8021e7
  800309:	e8 93 10 00 00       	call   8013a1 <_panic>

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
  800361:	68 ca 21 80 00       	push   $0x8021ca
  800366:	6a 23                	push   $0x23
  800368:	68 e7 21 80 00       	push   $0x8021e7
  80036d:	e8 2f 10 00 00       	call   8013a1 <_panic>

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

008003ba <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	53                   	push   %ebx
  8003be:	83 ec 04             	sub    $0x4,%esp
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003c4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003c6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003ca:	74 11                	je     8003dd <pgfault+0x23>
  8003cc:	89 d8                	mov    %ebx,%eax
  8003ce:	c1 e8 0c             	shr    $0xc,%eax
  8003d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003d8:	f6 c4 08             	test   $0x8,%ah
  8003db:	75 14                	jne    8003f1 <pgfault+0x37>
		panic("faulting access");
  8003dd:	83 ec 04             	sub    $0x4,%esp
  8003e0:	68 f5 21 80 00       	push   $0x8021f5
  8003e5:	6a 1e                	push   $0x1e
  8003e7:	68 05 22 80 00       	push   $0x802205
  8003ec:	e8 b0 0f 00 00       	call   8013a1 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8003f1:	83 ec 04             	sub    $0x4,%esp
  8003f4:	6a 07                	push   $0x7
  8003f6:	68 00 f0 7f 00       	push   $0x7ff000
  8003fb:	6a 00                	push   $0x0
  8003fd:	e8 87 fd ff ff       	call   800189 <sys_page_alloc>
	if (r < 0) {
  800402:	83 c4 10             	add    $0x10,%esp
  800405:	85 c0                	test   %eax,%eax
  800407:	79 12                	jns    80041b <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800409:	50                   	push   %eax
  80040a:	68 10 22 80 00       	push   $0x802210
  80040f:	6a 2c                	push   $0x2c
  800411:	68 05 22 80 00       	push   $0x802205
  800416:	e8 86 0f 00 00       	call   8013a1 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80041b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800421:	83 ec 04             	sub    $0x4,%esp
  800424:	68 00 10 00 00       	push   $0x1000
  800429:	53                   	push   %ebx
  80042a:	68 00 f0 7f 00       	push   $0x7ff000
  80042f:	e8 c5 17 00 00       	call   801bf9 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800434:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80043b:	53                   	push   %ebx
  80043c:	6a 00                	push   $0x0
  80043e:	68 00 f0 7f 00       	push   $0x7ff000
  800443:	6a 00                	push   $0x0
  800445:	e8 82 fd ff ff       	call   8001cc <sys_page_map>
	if (r < 0) {
  80044a:	83 c4 20             	add    $0x20,%esp
  80044d:	85 c0                	test   %eax,%eax
  80044f:	79 12                	jns    800463 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800451:	50                   	push   %eax
  800452:	68 10 22 80 00       	push   $0x802210
  800457:	6a 33                	push   $0x33
  800459:	68 05 22 80 00       	push   $0x802205
  80045e:	e8 3e 0f 00 00       	call   8013a1 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	68 00 f0 7f 00       	push   $0x7ff000
  80046b:	6a 00                	push   $0x0
  80046d:	e8 9c fd ff ff       	call   80020e <sys_page_unmap>
	if (r < 0) {
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	85 c0                	test   %eax,%eax
  800477:	79 12                	jns    80048b <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800479:	50                   	push   %eax
  80047a:	68 10 22 80 00       	push   $0x802210
  80047f:	6a 37                	push   $0x37
  800481:	68 05 22 80 00       	push   $0x802205
  800486:	e8 16 0f 00 00       	call   8013a1 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80048b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80048e:	c9                   	leave  
  80048f:	c3                   	ret    

00800490 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	57                   	push   %edi
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800499:	68 ba 03 80 00       	push   $0x8003ba
  80049e:	e8 a3 18 00 00       	call   801d46 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004a3:	b8 07 00 00 00       	mov    $0x7,%eax
  8004a8:	cd 30                	int    $0x30
  8004aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	85 c0                	test   %eax,%eax
  8004b2:	79 17                	jns    8004cb <fork+0x3b>
		panic("fork fault %e");
  8004b4:	83 ec 04             	sub    $0x4,%esp
  8004b7:	68 29 22 80 00       	push   $0x802229
  8004bc:	68 84 00 00 00       	push   $0x84
  8004c1:	68 05 22 80 00       	push   $0x802205
  8004c6:	e8 d6 0e 00 00       	call   8013a1 <_panic>
  8004cb:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004cd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d1:	75 24                	jne    8004f7 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004d3:	e8 73 fc ff ff       	call   80014b <sys_getenvid>
  8004d8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004dd:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8004e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004e8:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f2:	e9 64 01 00 00       	jmp    80065b <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8004f7:	83 ec 04             	sub    $0x4,%esp
  8004fa:	6a 07                	push   $0x7
  8004fc:	68 00 f0 bf ee       	push   $0xeebff000
  800501:	ff 75 e4             	pushl  -0x1c(%ebp)
  800504:	e8 80 fc ff ff       	call   800189 <sys_page_alloc>
  800509:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80050c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800511:	89 d8                	mov    %ebx,%eax
  800513:	c1 e8 16             	shr    $0x16,%eax
  800516:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80051d:	a8 01                	test   $0x1,%al
  80051f:	0f 84 fc 00 00 00    	je     800621 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800525:	89 d8                	mov    %ebx,%eax
  800527:	c1 e8 0c             	shr    $0xc,%eax
  80052a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800531:	f6 c2 01             	test   $0x1,%dl
  800534:	0f 84 e7 00 00 00    	je     800621 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80053a:	89 c6                	mov    %eax,%esi
  80053c:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80053f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800546:	f6 c6 04             	test   $0x4,%dh
  800549:	74 39                	je     800584 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80054b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800552:	83 ec 0c             	sub    $0xc,%esp
  800555:	25 07 0e 00 00       	and    $0xe07,%eax
  80055a:	50                   	push   %eax
  80055b:	56                   	push   %esi
  80055c:	57                   	push   %edi
  80055d:	56                   	push   %esi
  80055e:	6a 00                	push   $0x0
  800560:	e8 67 fc ff ff       	call   8001cc <sys_page_map>
		if (r < 0) {
  800565:	83 c4 20             	add    $0x20,%esp
  800568:	85 c0                	test   %eax,%eax
  80056a:	0f 89 b1 00 00 00    	jns    800621 <fork+0x191>
		    	panic("sys page map fault %e");
  800570:	83 ec 04             	sub    $0x4,%esp
  800573:	68 37 22 80 00       	push   $0x802237
  800578:	6a 54                	push   $0x54
  80057a:	68 05 22 80 00       	push   $0x802205
  80057f:	e8 1d 0e 00 00       	call   8013a1 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800584:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80058b:	f6 c2 02             	test   $0x2,%dl
  80058e:	75 0c                	jne    80059c <fork+0x10c>
  800590:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800597:	f6 c4 08             	test   $0x8,%ah
  80059a:	74 5b                	je     8005f7 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80059c:	83 ec 0c             	sub    $0xc,%esp
  80059f:	68 05 08 00 00       	push   $0x805
  8005a4:	56                   	push   %esi
  8005a5:	57                   	push   %edi
  8005a6:	56                   	push   %esi
  8005a7:	6a 00                	push   $0x0
  8005a9:	e8 1e fc ff ff       	call   8001cc <sys_page_map>
		if (r < 0) {
  8005ae:	83 c4 20             	add    $0x20,%esp
  8005b1:	85 c0                	test   %eax,%eax
  8005b3:	79 14                	jns    8005c9 <fork+0x139>
		    	panic("sys page map fault %e");
  8005b5:	83 ec 04             	sub    $0x4,%esp
  8005b8:	68 37 22 80 00       	push   $0x802237
  8005bd:	6a 5b                	push   $0x5b
  8005bf:	68 05 22 80 00       	push   $0x802205
  8005c4:	e8 d8 0d 00 00       	call   8013a1 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005c9:	83 ec 0c             	sub    $0xc,%esp
  8005cc:	68 05 08 00 00       	push   $0x805
  8005d1:	56                   	push   %esi
  8005d2:	6a 00                	push   $0x0
  8005d4:	56                   	push   %esi
  8005d5:	6a 00                	push   $0x0
  8005d7:	e8 f0 fb ff ff       	call   8001cc <sys_page_map>
		if (r < 0) {
  8005dc:	83 c4 20             	add    $0x20,%esp
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	79 3e                	jns    800621 <fork+0x191>
		    	panic("sys page map fault %e");
  8005e3:	83 ec 04             	sub    $0x4,%esp
  8005e6:	68 37 22 80 00       	push   $0x802237
  8005eb:	6a 5f                	push   $0x5f
  8005ed:	68 05 22 80 00       	push   $0x802205
  8005f2:	e8 aa 0d 00 00       	call   8013a1 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8005f7:	83 ec 0c             	sub    $0xc,%esp
  8005fa:	6a 05                	push   $0x5
  8005fc:	56                   	push   %esi
  8005fd:	57                   	push   %edi
  8005fe:	56                   	push   %esi
  8005ff:	6a 00                	push   $0x0
  800601:	e8 c6 fb ff ff       	call   8001cc <sys_page_map>
		if (r < 0) {
  800606:	83 c4 20             	add    $0x20,%esp
  800609:	85 c0                	test   %eax,%eax
  80060b:	79 14                	jns    800621 <fork+0x191>
		    	panic("sys page map fault %e");
  80060d:	83 ec 04             	sub    $0x4,%esp
  800610:	68 37 22 80 00       	push   $0x802237
  800615:	6a 64                	push   $0x64
  800617:	68 05 22 80 00       	push   $0x802205
  80061c:	e8 80 0d 00 00       	call   8013a1 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800621:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800627:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80062d:	0f 85 de fe ff ff    	jne    800511 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800633:	a1 04 40 80 00       	mov    0x804004,%eax
  800638:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	50                   	push   %eax
  800642:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800645:	57                   	push   %edi
  800646:	e8 89 fc ff ff       	call   8002d4 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	6a 02                	push   $0x2
  800650:	57                   	push   %edi
  800651:	e8 fa fb ff ff       	call   800250 <sys_env_set_status>
	
	return envid;
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80065b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065e:	5b                   	pop    %ebx
  80065f:	5e                   	pop    %esi
  800660:	5f                   	pop    %edi
  800661:	5d                   	pop    %ebp
  800662:	c3                   	ret    

00800663 <sfork>:

envid_t
sfork(void)
{
  800663:	55                   	push   %ebp
  800664:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800666:	b8 00 00 00 00       	mov    $0x0,%eax
  80066b:	5d                   	pop    %ebp
  80066c:	c3                   	ret    

0080066d <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80066d:	55                   	push   %ebp
  80066e:	89 e5                	mov    %esp,%ebp
  800670:	56                   	push   %esi
  800671:	53                   	push   %ebx
  800672:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800675:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	53                   	push   %ebx
  80067f:	68 50 22 80 00       	push   $0x802250
  800684:	e8 f1 0d 00 00       	call   80147a <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800689:	c7 04 24 93 00 80 00 	movl   $0x800093,(%esp)
  800690:	e8 e5 fc ff ff       	call   80037a <sys_thread_create>
  800695:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  800697:	83 c4 08             	add    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	68 50 22 80 00       	push   $0x802250
  8006a0:	e8 d5 0d 00 00       	call   80147a <cprintf>
	return id;
}
  8006a5:	89 f0                	mov    %esi,%eax
  8006a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006aa:	5b                   	pop    %ebx
  8006ab:	5e                   	pop    %esi
  8006ac:	5d                   	pop    %ebp
  8006ad:	c3                   	ret    

008006ae <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b4:	05 00 00 00 30       	add    $0x30000000,%eax
  8006b9:	c1 e8 0c             	shr    $0xc,%eax
}
  8006bc:	5d                   	pop    %ebp
  8006bd:	c3                   	ret    

008006be <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c4:	05 00 00 00 30       	add    $0x30000000,%eax
  8006c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006ce:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006db:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006e0:	89 c2                	mov    %eax,%edx
  8006e2:	c1 ea 16             	shr    $0x16,%edx
  8006e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8006ec:	f6 c2 01             	test   $0x1,%dl
  8006ef:	74 11                	je     800702 <fd_alloc+0x2d>
  8006f1:	89 c2                	mov    %eax,%edx
  8006f3:	c1 ea 0c             	shr    $0xc,%edx
  8006f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006fd:	f6 c2 01             	test   $0x1,%dl
  800700:	75 09                	jne    80070b <fd_alloc+0x36>
			*fd_store = fd;
  800702:	89 01                	mov    %eax,(%ecx)
			return 0;
  800704:	b8 00 00 00 00       	mov    $0x0,%eax
  800709:	eb 17                	jmp    800722 <fd_alloc+0x4d>
  80070b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800710:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800715:	75 c9                	jne    8006e0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800717:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80071d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80072a:	83 f8 1f             	cmp    $0x1f,%eax
  80072d:	77 36                	ja     800765 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80072f:	c1 e0 0c             	shl    $0xc,%eax
  800732:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800737:	89 c2                	mov    %eax,%edx
  800739:	c1 ea 16             	shr    $0x16,%edx
  80073c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800743:	f6 c2 01             	test   $0x1,%dl
  800746:	74 24                	je     80076c <fd_lookup+0x48>
  800748:	89 c2                	mov    %eax,%edx
  80074a:	c1 ea 0c             	shr    $0xc,%edx
  80074d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800754:	f6 c2 01             	test   $0x1,%dl
  800757:	74 1a                	je     800773 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800759:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075c:	89 02                	mov    %eax,(%edx)
	return 0;
  80075e:	b8 00 00 00 00       	mov    $0x0,%eax
  800763:	eb 13                	jmp    800778 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800765:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076a:	eb 0c                	jmp    800778 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80076c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800771:	eb 05                	jmp    800778 <fd_lookup+0x54>
  800773:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800783:	ba f0 22 80 00       	mov    $0x8022f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800788:	eb 13                	jmp    80079d <dev_lookup+0x23>
  80078a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80078d:	39 08                	cmp    %ecx,(%eax)
  80078f:	75 0c                	jne    80079d <dev_lookup+0x23>
			*dev = devtab[i];
  800791:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800794:	89 01                	mov    %eax,(%ecx)
			return 0;
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
  80079b:	eb 2e                	jmp    8007cb <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80079d:	8b 02                	mov    (%edx),%eax
  80079f:	85 c0                	test   %eax,%eax
  8007a1:	75 e7                	jne    80078a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8007a8:	8b 40 7c             	mov    0x7c(%eax),%eax
  8007ab:	83 ec 04             	sub    $0x4,%esp
  8007ae:	51                   	push   %ecx
  8007af:	50                   	push   %eax
  8007b0:	68 74 22 80 00       	push   $0x802274
  8007b5:	e8 c0 0c 00 00       	call   80147a <cprintf>
	*dev = 0;
  8007ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    

008007cd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	56                   	push   %esi
  8007d1:	53                   	push   %ebx
  8007d2:	83 ec 10             	sub    $0x10,%esp
  8007d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007de:	50                   	push   %eax
  8007df:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8007e5:	c1 e8 0c             	shr    $0xc,%eax
  8007e8:	50                   	push   %eax
  8007e9:	e8 36 ff ff ff       	call   800724 <fd_lookup>
  8007ee:	83 c4 08             	add    $0x8,%esp
  8007f1:	85 c0                	test   %eax,%eax
  8007f3:	78 05                	js     8007fa <fd_close+0x2d>
	    || fd != fd2)
  8007f5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8007f8:	74 0c                	je     800806 <fd_close+0x39>
		return (must_exist ? r : 0);
  8007fa:	84 db                	test   %bl,%bl
  8007fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800801:	0f 44 c2             	cmove  %edx,%eax
  800804:	eb 41                	jmp    800847 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800806:	83 ec 08             	sub    $0x8,%esp
  800809:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080c:	50                   	push   %eax
  80080d:	ff 36                	pushl  (%esi)
  80080f:	e8 66 ff ff ff       	call   80077a <dev_lookup>
  800814:	89 c3                	mov    %eax,%ebx
  800816:	83 c4 10             	add    $0x10,%esp
  800819:	85 c0                	test   %eax,%eax
  80081b:	78 1a                	js     800837 <fd_close+0x6a>
		if (dev->dev_close)
  80081d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800820:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800823:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800828:	85 c0                	test   %eax,%eax
  80082a:	74 0b                	je     800837 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80082c:	83 ec 0c             	sub    $0xc,%esp
  80082f:	56                   	push   %esi
  800830:	ff d0                	call   *%eax
  800832:	89 c3                	mov    %eax,%ebx
  800834:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800837:	83 ec 08             	sub    $0x8,%esp
  80083a:	56                   	push   %esi
  80083b:	6a 00                	push   $0x0
  80083d:	e8 cc f9 ff ff       	call   80020e <sys_page_unmap>
	return r;
  800842:	83 c4 10             	add    $0x10,%esp
  800845:	89 d8                	mov    %ebx,%eax
}
  800847:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800854:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800857:	50                   	push   %eax
  800858:	ff 75 08             	pushl  0x8(%ebp)
  80085b:	e8 c4 fe ff ff       	call   800724 <fd_lookup>
  800860:	83 c4 08             	add    $0x8,%esp
  800863:	85 c0                	test   %eax,%eax
  800865:	78 10                	js     800877 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	6a 01                	push   $0x1
  80086c:	ff 75 f4             	pushl  -0xc(%ebp)
  80086f:	e8 59 ff ff ff       	call   8007cd <fd_close>
  800874:	83 c4 10             	add    $0x10,%esp
}
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <close_all>:

void
close_all(void)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800880:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800885:	83 ec 0c             	sub    $0xc,%esp
  800888:	53                   	push   %ebx
  800889:	e8 c0 ff ff ff       	call   80084e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80088e:	83 c3 01             	add    $0x1,%ebx
  800891:	83 c4 10             	add    $0x10,%esp
  800894:	83 fb 20             	cmp    $0x20,%ebx
  800897:	75 ec                	jne    800885 <close_all+0xc>
		close(i);
}
  800899:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089c:	c9                   	leave  
  80089d:	c3                   	ret    

0080089e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	57                   	push   %edi
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
  8008a4:	83 ec 2c             	sub    $0x2c,%esp
  8008a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008ad:	50                   	push   %eax
  8008ae:	ff 75 08             	pushl  0x8(%ebp)
  8008b1:	e8 6e fe ff ff       	call   800724 <fd_lookup>
  8008b6:	83 c4 08             	add    $0x8,%esp
  8008b9:	85 c0                	test   %eax,%eax
  8008bb:	0f 88 c1 00 00 00    	js     800982 <dup+0xe4>
		return r;
	close(newfdnum);
  8008c1:	83 ec 0c             	sub    $0xc,%esp
  8008c4:	56                   	push   %esi
  8008c5:	e8 84 ff ff ff       	call   80084e <close>

	newfd = INDEX2FD(newfdnum);
  8008ca:	89 f3                	mov    %esi,%ebx
  8008cc:	c1 e3 0c             	shl    $0xc,%ebx
  8008cf:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008d5:	83 c4 04             	add    $0x4,%esp
  8008d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008db:	e8 de fd ff ff       	call   8006be <fd2data>
  8008e0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008e2:	89 1c 24             	mov    %ebx,(%esp)
  8008e5:	e8 d4 fd ff ff       	call   8006be <fd2data>
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8008f0:	89 f8                	mov    %edi,%eax
  8008f2:	c1 e8 16             	shr    $0x16,%eax
  8008f5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8008fc:	a8 01                	test   $0x1,%al
  8008fe:	74 37                	je     800937 <dup+0x99>
  800900:	89 f8                	mov    %edi,%eax
  800902:	c1 e8 0c             	shr    $0xc,%eax
  800905:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80090c:	f6 c2 01             	test   $0x1,%dl
  80090f:	74 26                	je     800937 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800911:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800918:	83 ec 0c             	sub    $0xc,%esp
  80091b:	25 07 0e 00 00       	and    $0xe07,%eax
  800920:	50                   	push   %eax
  800921:	ff 75 d4             	pushl  -0x2c(%ebp)
  800924:	6a 00                	push   $0x0
  800926:	57                   	push   %edi
  800927:	6a 00                	push   $0x0
  800929:	e8 9e f8 ff ff       	call   8001cc <sys_page_map>
  80092e:	89 c7                	mov    %eax,%edi
  800930:	83 c4 20             	add    $0x20,%esp
  800933:	85 c0                	test   %eax,%eax
  800935:	78 2e                	js     800965 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800937:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80093a:	89 d0                	mov    %edx,%eax
  80093c:	c1 e8 0c             	shr    $0xc,%eax
  80093f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800946:	83 ec 0c             	sub    $0xc,%esp
  800949:	25 07 0e 00 00       	and    $0xe07,%eax
  80094e:	50                   	push   %eax
  80094f:	53                   	push   %ebx
  800950:	6a 00                	push   $0x0
  800952:	52                   	push   %edx
  800953:	6a 00                	push   $0x0
  800955:	e8 72 f8 ff ff       	call   8001cc <sys_page_map>
  80095a:	89 c7                	mov    %eax,%edi
  80095c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80095f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800961:	85 ff                	test   %edi,%edi
  800963:	79 1d                	jns    800982 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800965:	83 ec 08             	sub    $0x8,%esp
  800968:	53                   	push   %ebx
  800969:	6a 00                	push   $0x0
  80096b:	e8 9e f8 ff ff       	call   80020e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800970:	83 c4 08             	add    $0x8,%esp
  800973:	ff 75 d4             	pushl  -0x2c(%ebp)
  800976:	6a 00                	push   $0x0
  800978:	e8 91 f8 ff ff       	call   80020e <sys_page_unmap>
	return r;
  80097d:	83 c4 10             	add    $0x10,%esp
  800980:	89 f8                	mov    %edi,%eax
}
  800982:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800985:	5b                   	pop    %ebx
  800986:	5e                   	pop    %esi
  800987:	5f                   	pop    %edi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	53                   	push   %ebx
  80098e:	83 ec 14             	sub    $0x14,%esp
  800991:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800994:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800997:	50                   	push   %eax
  800998:	53                   	push   %ebx
  800999:	e8 86 fd ff ff       	call   800724 <fd_lookup>
  80099e:	83 c4 08             	add    $0x8,%esp
  8009a1:	89 c2                	mov    %eax,%edx
  8009a3:	85 c0                	test   %eax,%eax
  8009a5:	78 6d                	js     800a14 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009ad:	50                   	push   %eax
  8009ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b1:	ff 30                	pushl  (%eax)
  8009b3:	e8 c2 fd ff ff       	call   80077a <dev_lookup>
  8009b8:	83 c4 10             	add    $0x10,%esp
  8009bb:	85 c0                	test   %eax,%eax
  8009bd:	78 4c                	js     800a0b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009c2:	8b 42 08             	mov    0x8(%edx),%eax
  8009c5:	83 e0 03             	and    $0x3,%eax
  8009c8:	83 f8 01             	cmp    $0x1,%eax
  8009cb:	75 21                	jne    8009ee <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8009d2:	8b 40 7c             	mov    0x7c(%eax),%eax
  8009d5:	83 ec 04             	sub    $0x4,%esp
  8009d8:	53                   	push   %ebx
  8009d9:	50                   	push   %eax
  8009da:	68 b5 22 80 00       	push   $0x8022b5
  8009df:	e8 96 0a 00 00       	call   80147a <cprintf>
		return -E_INVAL;
  8009e4:	83 c4 10             	add    $0x10,%esp
  8009e7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8009ec:	eb 26                	jmp    800a14 <read+0x8a>
	}
	if (!dev->dev_read)
  8009ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f1:	8b 40 08             	mov    0x8(%eax),%eax
  8009f4:	85 c0                	test   %eax,%eax
  8009f6:	74 17                	je     800a0f <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8009f8:	83 ec 04             	sub    $0x4,%esp
  8009fb:	ff 75 10             	pushl  0x10(%ebp)
  8009fe:	ff 75 0c             	pushl  0xc(%ebp)
  800a01:	52                   	push   %edx
  800a02:	ff d0                	call   *%eax
  800a04:	89 c2                	mov    %eax,%edx
  800a06:	83 c4 10             	add    $0x10,%esp
  800a09:	eb 09                	jmp    800a14 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a0b:	89 c2                	mov    %eax,%edx
  800a0d:	eb 05                	jmp    800a14 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a0f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a14:	89 d0                	mov    %edx,%eax
  800a16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a19:	c9                   	leave  
  800a1a:	c3                   	ret    

00800a1b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	57                   	push   %edi
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
  800a21:	83 ec 0c             	sub    $0xc,%esp
  800a24:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a27:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a2f:	eb 21                	jmp    800a52 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a31:	83 ec 04             	sub    $0x4,%esp
  800a34:	89 f0                	mov    %esi,%eax
  800a36:	29 d8                	sub    %ebx,%eax
  800a38:	50                   	push   %eax
  800a39:	89 d8                	mov    %ebx,%eax
  800a3b:	03 45 0c             	add    0xc(%ebp),%eax
  800a3e:	50                   	push   %eax
  800a3f:	57                   	push   %edi
  800a40:	e8 45 ff ff ff       	call   80098a <read>
		if (m < 0)
  800a45:	83 c4 10             	add    $0x10,%esp
  800a48:	85 c0                	test   %eax,%eax
  800a4a:	78 10                	js     800a5c <readn+0x41>
			return m;
		if (m == 0)
  800a4c:	85 c0                	test   %eax,%eax
  800a4e:	74 0a                	je     800a5a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a50:	01 c3                	add    %eax,%ebx
  800a52:	39 f3                	cmp    %esi,%ebx
  800a54:	72 db                	jb     800a31 <readn+0x16>
  800a56:	89 d8                	mov    %ebx,%eax
  800a58:	eb 02                	jmp    800a5c <readn+0x41>
  800a5a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5f                   	pop    %edi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	53                   	push   %ebx
  800a68:	83 ec 14             	sub    $0x14,%esp
  800a6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a6e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a71:	50                   	push   %eax
  800a72:	53                   	push   %ebx
  800a73:	e8 ac fc ff ff       	call   800724 <fd_lookup>
  800a78:	83 c4 08             	add    $0x8,%esp
  800a7b:	89 c2                	mov    %eax,%edx
  800a7d:	85 c0                	test   %eax,%eax
  800a7f:	78 68                	js     800ae9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a81:	83 ec 08             	sub    $0x8,%esp
  800a84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a87:	50                   	push   %eax
  800a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a8b:	ff 30                	pushl  (%eax)
  800a8d:	e8 e8 fc ff ff       	call   80077a <dev_lookup>
  800a92:	83 c4 10             	add    $0x10,%esp
  800a95:	85 c0                	test   %eax,%eax
  800a97:	78 47                	js     800ae0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a9c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800aa0:	75 21                	jne    800ac3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800aa2:	a1 04 40 80 00       	mov    0x804004,%eax
  800aa7:	8b 40 7c             	mov    0x7c(%eax),%eax
  800aaa:	83 ec 04             	sub    $0x4,%esp
  800aad:	53                   	push   %ebx
  800aae:	50                   	push   %eax
  800aaf:	68 d1 22 80 00       	push   $0x8022d1
  800ab4:	e8 c1 09 00 00       	call   80147a <cprintf>
		return -E_INVAL;
  800ab9:	83 c4 10             	add    $0x10,%esp
  800abc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ac1:	eb 26                	jmp    800ae9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ac3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac6:	8b 52 0c             	mov    0xc(%edx),%edx
  800ac9:	85 d2                	test   %edx,%edx
  800acb:	74 17                	je     800ae4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800acd:	83 ec 04             	sub    $0x4,%esp
  800ad0:	ff 75 10             	pushl  0x10(%ebp)
  800ad3:	ff 75 0c             	pushl  0xc(%ebp)
  800ad6:	50                   	push   %eax
  800ad7:	ff d2                	call   *%edx
  800ad9:	89 c2                	mov    %eax,%edx
  800adb:	83 c4 10             	add    $0x10,%esp
  800ade:	eb 09                	jmp    800ae9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ae0:	89 c2                	mov    %eax,%edx
  800ae2:	eb 05                	jmp    800ae9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ae4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800ae9:	89 d0                	mov    %edx,%eax
  800aeb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aee:	c9                   	leave  
  800aef:	c3                   	ret    

00800af0 <seek>:

int
seek(int fdnum, off_t offset)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800af6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800af9:	50                   	push   %eax
  800afa:	ff 75 08             	pushl  0x8(%ebp)
  800afd:	e8 22 fc ff ff       	call   800724 <fd_lookup>
  800b02:	83 c4 08             	add    $0x8,%esp
  800b05:	85 c0                	test   %eax,%eax
  800b07:	78 0e                	js     800b17 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b09:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b17:	c9                   	leave  
  800b18:	c3                   	ret    

00800b19 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	53                   	push   %ebx
  800b1d:	83 ec 14             	sub    $0x14,%esp
  800b20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b23:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b26:	50                   	push   %eax
  800b27:	53                   	push   %ebx
  800b28:	e8 f7 fb ff ff       	call   800724 <fd_lookup>
  800b2d:	83 c4 08             	add    $0x8,%esp
  800b30:	89 c2                	mov    %eax,%edx
  800b32:	85 c0                	test   %eax,%eax
  800b34:	78 65                	js     800b9b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b36:	83 ec 08             	sub    $0x8,%esp
  800b39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b3c:	50                   	push   %eax
  800b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b40:	ff 30                	pushl  (%eax)
  800b42:	e8 33 fc ff ff       	call   80077a <dev_lookup>
  800b47:	83 c4 10             	add    $0x10,%esp
  800b4a:	85 c0                	test   %eax,%eax
  800b4c:	78 44                	js     800b92 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b51:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b55:	75 21                	jne    800b78 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b57:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b5c:	8b 40 7c             	mov    0x7c(%eax),%eax
  800b5f:	83 ec 04             	sub    $0x4,%esp
  800b62:	53                   	push   %ebx
  800b63:	50                   	push   %eax
  800b64:	68 94 22 80 00       	push   $0x802294
  800b69:	e8 0c 09 00 00       	call   80147a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b6e:	83 c4 10             	add    $0x10,%esp
  800b71:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b76:	eb 23                	jmp    800b9b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b7b:	8b 52 18             	mov    0x18(%edx),%edx
  800b7e:	85 d2                	test   %edx,%edx
  800b80:	74 14                	je     800b96 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b82:	83 ec 08             	sub    $0x8,%esp
  800b85:	ff 75 0c             	pushl  0xc(%ebp)
  800b88:	50                   	push   %eax
  800b89:	ff d2                	call   *%edx
  800b8b:	89 c2                	mov    %eax,%edx
  800b8d:	83 c4 10             	add    $0x10,%esp
  800b90:	eb 09                	jmp    800b9b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b92:	89 c2                	mov    %eax,%edx
  800b94:	eb 05                	jmp    800b9b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800b96:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800b9b:	89 d0                	mov    %edx,%eax
  800b9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 14             	sub    $0x14,%esp
  800ba9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800baf:	50                   	push   %eax
  800bb0:	ff 75 08             	pushl  0x8(%ebp)
  800bb3:	e8 6c fb ff ff       	call   800724 <fd_lookup>
  800bb8:	83 c4 08             	add    $0x8,%esp
  800bbb:	89 c2                	mov    %eax,%edx
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	78 58                	js     800c19 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bc1:	83 ec 08             	sub    $0x8,%esp
  800bc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bc7:	50                   	push   %eax
  800bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bcb:	ff 30                	pushl  (%eax)
  800bcd:	e8 a8 fb ff ff       	call   80077a <dev_lookup>
  800bd2:	83 c4 10             	add    $0x10,%esp
  800bd5:	85 c0                	test   %eax,%eax
  800bd7:	78 37                	js     800c10 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bdc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800be0:	74 32                	je     800c14 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800be2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800be5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800bec:	00 00 00 
	stat->st_isdir = 0;
  800bef:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bf6:	00 00 00 
	stat->st_dev = dev;
  800bf9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800bff:	83 ec 08             	sub    $0x8,%esp
  800c02:	53                   	push   %ebx
  800c03:	ff 75 f0             	pushl  -0x10(%ebp)
  800c06:	ff 50 14             	call   *0x14(%eax)
  800c09:	89 c2                	mov    %eax,%edx
  800c0b:	83 c4 10             	add    $0x10,%esp
  800c0e:	eb 09                	jmp    800c19 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c10:	89 c2                	mov    %eax,%edx
  800c12:	eb 05                	jmp    800c19 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c14:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c19:	89 d0                	mov    %edx,%eax
  800c1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c25:	83 ec 08             	sub    $0x8,%esp
  800c28:	6a 00                	push   $0x0
  800c2a:	ff 75 08             	pushl  0x8(%ebp)
  800c2d:	e8 e3 01 00 00       	call   800e15 <open>
  800c32:	89 c3                	mov    %eax,%ebx
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	85 c0                	test   %eax,%eax
  800c39:	78 1b                	js     800c56 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c3b:	83 ec 08             	sub    $0x8,%esp
  800c3e:	ff 75 0c             	pushl  0xc(%ebp)
  800c41:	50                   	push   %eax
  800c42:	e8 5b ff ff ff       	call   800ba2 <fstat>
  800c47:	89 c6                	mov    %eax,%esi
	close(fd);
  800c49:	89 1c 24             	mov    %ebx,(%esp)
  800c4c:	e8 fd fb ff ff       	call   80084e <close>
	return r;
  800c51:	83 c4 10             	add    $0x10,%esp
  800c54:	89 f0                	mov    %esi,%eax
}
  800c56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	89 c6                	mov    %eax,%esi
  800c64:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c66:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c6d:	75 12                	jne    800c81 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c6f:	83 ec 0c             	sub    $0xc,%esp
  800c72:	6a 01                	push   $0x1
  800c74:	e8 39 12 00 00       	call   801eb2 <ipc_find_env>
  800c79:	a3 00 40 80 00       	mov    %eax,0x804000
  800c7e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c81:	6a 07                	push   $0x7
  800c83:	68 00 50 80 00       	push   $0x805000
  800c88:	56                   	push   %esi
  800c89:	ff 35 00 40 80 00    	pushl  0x804000
  800c8f:	e8 bc 11 00 00       	call   801e50 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c94:	83 c4 0c             	add    $0xc,%esp
  800c97:	6a 00                	push   $0x0
  800c99:	53                   	push   %ebx
  800c9a:	6a 00                	push   $0x0
  800c9c:	e8 34 11 00 00       	call   801dd5 <ipc_recv>
}
  800ca1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb1:	8b 40 0c             	mov    0xc(%eax),%eax
  800cb4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbc:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ccb:	e8 8d ff ff ff       	call   800c5d <fsipc>
}
  800cd0:	c9                   	leave  
  800cd1:	c3                   	ret    

00800cd2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdb:	8b 40 0c             	mov    0xc(%eax),%eax
  800cde:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ce3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce8:	b8 06 00 00 00       	mov    $0x6,%eax
  800ced:	e8 6b ff ff ff       	call   800c5d <fsipc>
}
  800cf2:	c9                   	leave  
  800cf3:	c3                   	ret    

00800cf4 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 04             	sub    $0x4,%esp
  800cfb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800d01:	8b 40 0c             	mov    0xc(%eax),%eax
  800d04:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d09:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d13:	e8 45 ff ff ff       	call   800c5d <fsipc>
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	78 2c                	js     800d48 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d1c:	83 ec 08             	sub    $0x8,%esp
  800d1f:	68 00 50 80 00       	push   $0x805000
  800d24:	53                   	push   %ebx
  800d25:	e8 d5 0c 00 00       	call   8019ff <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d2a:	a1 80 50 80 00       	mov    0x805080,%eax
  800d2f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d35:	a1 84 50 80 00       	mov    0x805084,%eax
  800d3a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    

00800d4d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	83 ec 0c             	sub    $0xc,%esp
  800d53:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	8b 52 0c             	mov    0xc(%edx),%edx
  800d5c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d62:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d67:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d6c:	0f 47 c2             	cmova  %edx,%eax
  800d6f:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d74:	50                   	push   %eax
  800d75:	ff 75 0c             	pushl  0xc(%ebp)
  800d78:	68 08 50 80 00       	push   $0x805008
  800d7d:	e8 0f 0e 00 00       	call   801b91 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d82:	ba 00 00 00 00       	mov    $0x0,%edx
  800d87:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8c:	e8 cc fe ff ff       	call   800c5d <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800d91:	c9                   	leave  
  800d92:	c3                   	ret    

00800d93 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
  800d98:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	8b 40 0c             	mov    0xc(%eax),%eax
  800da1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800da6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800dac:	ba 00 00 00 00       	mov    $0x0,%edx
  800db1:	b8 03 00 00 00       	mov    $0x3,%eax
  800db6:	e8 a2 fe ff ff       	call   800c5d <fsipc>
  800dbb:	89 c3                	mov    %eax,%ebx
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	78 4b                	js     800e0c <devfile_read+0x79>
		return r;
	assert(r <= n);
  800dc1:	39 c6                	cmp    %eax,%esi
  800dc3:	73 16                	jae    800ddb <devfile_read+0x48>
  800dc5:	68 00 23 80 00       	push   $0x802300
  800dca:	68 07 23 80 00       	push   $0x802307
  800dcf:	6a 7c                	push   $0x7c
  800dd1:	68 1c 23 80 00       	push   $0x80231c
  800dd6:	e8 c6 05 00 00       	call   8013a1 <_panic>
	assert(r <= PGSIZE);
  800ddb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800de0:	7e 16                	jle    800df8 <devfile_read+0x65>
  800de2:	68 27 23 80 00       	push   $0x802327
  800de7:	68 07 23 80 00       	push   $0x802307
  800dec:	6a 7d                	push   $0x7d
  800dee:	68 1c 23 80 00       	push   $0x80231c
  800df3:	e8 a9 05 00 00       	call   8013a1 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800df8:	83 ec 04             	sub    $0x4,%esp
  800dfb:	50                   	push   %eax
  800dfc:	68 00 50 80 00       	push   $0x805000
  800e01:	ff 75 0c             	pushl  0xc(%ebp)
  800e04:	e8 88 0d 00 00       	call   801b91 <memmove>
	return r;
  800e09:	83 c4 10             	add    $0x10,%esp
}
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	53                   	push   %ebx
  800e19:	83 ec 20             	sub    $0x20,%esp
  800e1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e1f:	53                   	push   %ebx
  800e20:	e8 a1 0b 00 00       	call   8019c6 <strlen>
  800e25:	83 c4 10             	add    $0x10,%esp
  800e28:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e2d:	7f 67                	jg     800e96 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e2f:	83 ec 0c             	sub    $0xc,%esp
  800e32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e35:	50                   	push   %eax
  800e36:	e8 9a f8 ff ff       	call   8006d5 <fd_alloc>
  800e3b:	83 c4 10             	add    $0x10,%esp
		return r;
  800e3e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e40:	85 c0                	test   %eax,%eax
  800e42:	78 57                	js     800e9b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e44:	83 ec 08             	sub    $0x8,%esp
  800e47:	53                   	push   %ebx
  800e48:	68 00 50 80 00       	push   $0x805000
  800e4d:	e8 ad 0b 00 00       	call   8019ff <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e55:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e62:	e8 f6 fd ff ff       	call   800c5d <fsipc>
  800e67:	89 c3                	mov    %eax,%ebx
  800e69:	83 c4 10             	add    $0x10,%esp
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	79 14                	jns    800e84 <open+0x6f>
		fd_close(fd, 0);
  800e70:	83 ec 08             	sub    $0x8,%esp
  800e73:	6a 00                	push   $0x0
  800e75:	ff 75 f4             	pushl  -0xc(%ebp)
  800e78:	e8 50 f9 ff ff       	call   8007cd <fd_close>
		return r;
  800e7d:	83 c4 10             	add    $0x10,%esp
  800e80:	89 da                	mov    %ebx,%edx
  800e82:	eb 17                	jmp    800e9b <open+0x86>
	}

	return fd2num(fd);
  800e84:	83 ec 0c             	sub    $0xc,%esp
  800e87:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8a:	e8 1f f8 ff ff       	call   8006ae <fd2num>
  800e8f:	89 c2                	mov    %eax,%edx
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	eb 05                	jmp    800e9b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800e96:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800e9b:	89 d0                	mov    %edx,%eax
  800e9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea0:	c9                   	leave  
  800ea1:	c3                   	ret    

00800ea2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ea8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ead:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb2:	e8 a6 fd ff ff       	call   800c5d <fsipc>
}
  800eb7:	c9                   	leave  
  800eb8:	c3                   	ret    

00800eb9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
  800ebe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ec1:	83 ec 0c             	sub    $0xc,%esp
  800ec4:	ff 75 08             	pushl  0x8(%ebp)
  800ec7:	e8 f2 f7 ff ff       	call   8006be <fd2data>
  800ecc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ece:	83 c4 08             	add    $0x8,%esp
  800ed1:	68 33 23 80 00       	push   $0x802333
  800ed6:	53                   	push   %ebx
  800ed7:	e8 23 0b 00 00       	call   8019ff <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800edc:	8b 46 04             	mov    0x4(%esi),%eax
  800edf:	2b 06                	sub    (%esi),%eax
  800ee1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ee7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800eee:	00 00 00 
	stat->st_dev = &devpipe;
  800ef1:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ef8:	30 80 00 
	return 0;
}
  800efb:	b8 00 00 00 00       	mov    $0x0,%eax
  800f00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	53                   	push   %ebx
  800f0b:	83 ec 0c             	sub    $0xc,%esp
  800f0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f11:	53                   	push   %ebx
  800f12:	6a 00                	push   $0x0
  800f14:	e8 f5 f2 ff ff       	call   80020e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f19:	89 1c 24             	mov    %ebx,(%esp)
  800f1c:	e8 9d f7 ff ff       	call   8006be <fd2data>
  800f21:	83 c4 08             	add    $0x8,%esp
  800f24:	50                   	push   %eax
  800f25:	6a 00                	push   $0x0
  800f27:	e8 e2 f2 ff ff       	call   80020e <sys_page_unmap>
}
  800f2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2f:	c9                   	leave  
  800f30:	c3                   	ret    

00800f31 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	57                   	push   %edi
  800f35:	56                   	push   %esi
  800f36:	53                   	push   %ebx
  800f37:	83 ec 1c             	sub    $0x1c,%esp
  800f3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f3d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f3f:	a1 04 40 80 00       	mov    0x804004,%eax
  800f44:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	ff 75 e0             	pushl  -0x20(%ebp)
  800f50:	e8 9f 0f 00 00       	call   801ef4 <pageref>
  800f55:	89 c3                	mov    %eax,%ebx
  800f57:	89 3c 24             	mov    %edi,(%esp)
  800f5a:	e8 95 0f 00 00       	call   801ef4 <pageref>
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	39 c3                	cmp    %eax,%ebx
  800f64:	0f 94 c1             	sete   %cl
  800f67:	0f b6 c9             	movzbl %cl,%ecx
  800f6a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f6d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f73:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  800f79:	39 ce                	cmp    %ecx,%esi
  800f7b:	74 1e                	je     800f9b <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800f7d:	39 c3                	cmp    %eax,%ebx
  800f7f:	75 be                	jne    800f3f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f81:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  800f87:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f8a:	50                   	push   %eax
  800f8b:	56                   	push   %esi
  800f8c:	68 3a 23 80 00       	push   $0x80233a
  800f91:	e8 e4 04 00 00       	call   80147a <cprintf>
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	eb a4                	jmp    800f3f <_pipeisclosed+0xe>
	}
}
  800f9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
  800fac:	83 ec 28             	sub    $0x28,%esp
  800faf:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800fb2:	56                   	push   %esi
  800fb3:	e8 06 f7 ff ff       	call   8006be <fd2data>
  800fb8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	bf 00 00 00 00       	mov    $0x0,%edi
  800fc2:	eb 4b                	jmp    80100f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fc4:	89 da                	mov    %ebx,%edx
  800fc6:	89 f0                	mov    %esi,%eax
  800fc8:	e8 64 ff ff ff       	call   800f31 <_pipeisclosed>
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	75 48                	jne    801019 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fd1:	e8 94 f1 ff ff       	call   80016a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fd6:	8b 43 04             	mov    0x4(%ebx),%eax
  800fd9:	8b 0b                	mov    (%ebx),%ecx
  800fdb:	8d 51 20             	lea    0x20(%ecx),%edx
  800fde:	39 d0                	cmp    %edx,%eax
  800fe0:	73 e2                	jae    800fc4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800fe2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800fe9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800fec:	89 c2                	mov    %eax,%edx
  800fee:	c1 fa 1f             	sar    $0x1f,%edx
  800ff1:	89 d1                	mov    %edx,%ecx
  800ff3:	c1 e9 1b             	shr    $0x1b,%ecx
  800ff6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ff9:	83 e2 1f             	and    $0x1f,%edx
  800ffc:	29 ca                	sub    %ecx,%edx
  800ffe:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801002:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801006:	83 c0 01             	add    $0x1,%eax
  801009:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80100c:	83 c7 01             	add    $0x1,%edi
  80100f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801012:	75 c2                	jne    800fd6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801014:	8b 45 10             	mov    0x10(%ebp),%eax
  801017:	eb 05                	jmp    80101e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801019:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80101e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801021:	5b                   	pop    %ebx
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	57                   	push   %edi
  80102a:	56                   	push   %esi
  80102b:	53                   	push   %ebx
  80102c:	83 ec 18             	sub    $0x18,%esp
  80102f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801032:	57                   	push   %edi
  801033:	e8 86 f6 ff ff       	call   8006be <fd2data>
  801038:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801042:	eb 3d                	jmp    801081 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801044:	85 db                	test   %ebx,%ebx
  801046:	74 04                	je     80104c <devpipe_read+0x26>
				return i;
  801048:	89 d8                	mov    %ebx,%eax
  80104a:	eb 44                	jmp    801090 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80104c:	89 f2                	mov    %esi,%edx
  80104e:	89 f8                	mov    %edi,%eax
  801050:	e8 dc fe ff ff       	call   800f31 <_pipeisclosed>
  801055:	85 c0                	test   %eax,%eax
  801057:	75 32                	jne    80108b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801059:	e8 0c f1 ff ff       	call   80016a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80105e:	8b 06                	mov    (%esi),%eax
  801060:	3b 46 04             	cmp    0x4(%esi),%eax
  801063:	74 df                	je     801044 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801065:	99                   	cltd   
  801066:	c1 ea 1b             	shr    $0x1b,%edx
  801069:	01 d0                	add    %edx,%eax
  80106b:	83 e0 1f             	and    $0x1f,%eax
  80106e:	29 d0                	sub    %edx,%eax
  801070:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801075:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801078:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80107b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80107e:	83 c3 01             	add    $0x1,%ebx
  801081:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801084:	75 d8                	jne    80105e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801086:	8b 45 10             	mov    0x10(%ebp),%eax
  801089:	eb 05                	jmp    801090 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80108b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801090:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801093:	5b                   	pop    %ebx
  801094:	5e                   	pop    %esi
  801095:	5f                   	pop    %edi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	56                   	push   %esi
  80109c:	53                   	push   %ebx
  80109d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8010a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a3:	50                   	push   %eax
  8010a4:	e8 2c f6 ff ff       	call   8006d5 <fd_alloc>
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	89 c2                	mov    %eax,%edx
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	0f 88 2c 01 00 00    	js     8011e2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010b6:	83 ec 04             	sub    $0x4,%esp
  8010b9:	68 07 04 00 00       	push   $0x407
  8010be:	ff 75 f4             	pushl  -0xc(%ebp)
  8010c1:	6a 00                	push   $0x0
  8010c3:	e8 c1 f0 ff ff       	call   800189 <sys_page_alloc>
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	89 c2                	mov    %eax,%edx
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	0f 88 0d 01 00 00    	js     8011e2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010db:	50                   	push   %eax
  8010dc:	e8 f4 f5 ff ff       	call   8006d5 <fd_alloc>
  8010e1:	89 c3                	mov    %eax,%ebx
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	0f 88 e2 00 00 00    	js     8011d0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010ee:	83 ec 04             	sub    $0x4,%esp
  8010f1:	68 07 04 00 00       	push   $0x407
  8010f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8010f9:	6a 00                	push   $0x0
  8010fb:	e8 89 f0 ff ff       	call   800189 <sys_page_alloc>
  801100:	89 c3                	mov    %eax,%ebx
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	85 c0                	test   %eax,%eax
  801107:	0f 88 c3 00 00 00    	js     8011d0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80110d:	83 ec 0c             	sub    $0xc,%esp
  801110:	ff 75 f4             	pushl  -0xc(%ebp)
  801113:	e8 a6 f5 ff ff       	call   8006be <fd2data>
  801118:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80111a:	83 c4 0c             	add    $0xc,%esp
  80111d:	68 07 04 00 00       	push   $0x407
  801122:	50                   	push   %eax
  801123:	6a 00                	push   $0x0
  801125:	e8 5f f0 ff ff       	call   800189 <sys_page_alloc>
  80112a:	89 c3                	mov    %eax,%ebx
  80112c:	83 c4 10             	add    $0x10,%esp
  80112f:	85 c0                	test   %eax,%eax
  801131:	0f 88 89 00 00 00    	js     8011c0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801137:	83 ec 0c             	sub    $0xc,%esp
  80113a:	ff 75 f0             	pushl  -0x10(%ebp)
  80113d:	e8 7c f5 ff ff       	call   8006be <fd2data>
  801142:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801149:	50                   	push   %eax
  80114a:	6a 00                	push   $0x0
  80114c:	56                   	push   %esi
  80114d:	6a 00                	push   $0x0
  80114f:	e8 78 f0 ff ff       	call   8001cc <sys_page_map>
  801154:	89 c3                	mov    %eax,%ebx
  801156:	83 c4 20             	add    $0x20,%esp
  801159:	85 c0                	test   %eax,%eax
  80115b:	78 55                	js     8011b2 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80115d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801163:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801166:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801172:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801178:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80117d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801180:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801187:	83 ec 0c             	sub    $0xc,%esp
  80118a:	ff 75 f4             	pushl  -0xc(%ebp)
  80118d:	e8 1c f5 ff ff       	call   8006ae <fd2num>
  801192:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801195:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801197:	83 c4 04             	add    $0x4,%esp
  80119a:	ff 75 f0             	pushl  -0x10(%ebp)
  80119d:	e8 0c f5 ff ff       	call   8006ae <fd2num>
  8011a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a5:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b0:	eb 30                	jmp    8011e2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011b2:	83 ec 08             	sub    $0x8,%esp
  8011b5:	56                   	push   %esi
  8011b6:	6a 00                	push   $0x0
  8011b8:	e8 51 f0 ff ff       	call   80020e <sys_page_unmap>
  8011bd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011c0:	83 ec 08             	sub    $0x8,%esp
  8011c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8011c6:	6a 00                	push   $0x0
  8011c8:	e8 41 f0 ff ff       	call   80020e <sys_page_unmap>
  8011cd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011d0:	83 ec 08             	sub    $0x8,%esp
  8011d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8011d6:	6a 00                	push   $0x0
  8011d8:	e8 31 f0 ff ff       	call   80020e <sys_page_unmap>
  8011dd:	83 c4 10             	add    $0x10,%esp
  8011e0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011e2:	89 d0                	mov    %edx,%eax
  8011e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011e7:	5b                   	pop    %ebx
  8011e8:	5e                   	pop    %esi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f4:	50                   	push   %eax
  8011f5:	ff 75 08             	pushl  0x8(%ebp)
  8011f8:	e8 27 f5 ff ff       	call   800724 <fd_lookup>
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	85 c0                	test   %eax,%eax
  801202:	78 18                	js     80121c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801204:	83 ec 0c             	sub    $0xc,%esp
  801207:	ff 75 f4             	pushl  -0xc(%ebp)
  80120a:	e8 af f4 ff ff       	call   8006be <fd2data>
	return _pipeisclosed(fd, p);
  80120f:	89 c2                	mov    %eax,%edx
  801211:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801214:	e8 18 fd ff ff       	call   800f31 <_pipeisclosed>
  801219:	83 c4 10             	add    $0x10,%esp
}
  80121c:	c9                   	leave  
  80121d:	c3                   	ret    

0080121e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801221:	b8 00 00 00 00       	mov    $0x0,%eax
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80122e:	68 52 23 80 00       	push   $0x802352
  801233:	ff 75 0c             	pushl  0xc(%ebp)
  801236:	e8 c4 07 00 00       	call   8019ff <strcpy>
	return 0;
}
  80123b:	b8 00 00 00 00       	mov    $0x0,%eax
  801240:	c9                   	leave  
  801241:	c3                   	ret    

00801242 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	57                   	push   %edi
  801246:	56                   	push   %esi
  801247:	53                   	push   %ebx
  801248:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80124e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801253:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801259:	eb 2d                	jmp    801288 <devcons_write+0x46>
		m = n - tot;
  80125b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80125e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801260:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801263:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801268:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80126b:	83 ec 04             	sub    $0x4,%esp
  80126e:	53                   	push   %ebx
  80126f:	03 45 0c             	add    0xc(%ebp),%eax
  801272:	50                   	push   %eax
  801273:	57                   	push   %edi
  801274:	e8 18 09 00 00       	call   801b91 <memmove>
		sys_cputs(buf, m);
  801279:	83 c4 08             	add    $0x8,%esp
  80127c:	53                   	push   %ebx
  80127d:	57                   	push   %edi
  80127e:	e8 4a ee ff ff       	call   8000cd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801283:	01 de                	add    %ebx,%esi
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	89 f0                	mov    %esi,%eax
  80128a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80128d:	72 cc                	jb     80125b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80128f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801292:	5b                   	pop    %ebx
  801293:	5e                   	pop    %esi
  801294:	5f                   	pop    %edi
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	83 ec 08             	sub    $0x8,%esp
  80129d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8012a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012a6:	74 2a                	je     8012d2 <devcons_read+0x3b>
  8012a8:	eb 05                	jmp    8012af <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012aa:	e8 bb ee ff ff       	call   80016a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012af:	e8 37 ee ff ff       	call   8000eb <sys_cgetc>
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	74 f2                	je     8012aa <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	78 16                	js     8012d2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012bc:	83 f8 04             	cmp    $0x4,%eax
  8012bf:	74 0c                	je     8012cd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c4:	88 02                	mov    %al,(%edx)
	return 1;
  8012c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012cb:	eb 05                	jmp    8012d2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012cd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012d2:	c9                   	leave  
  8012d3:	c3                   	ret    

008012d4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012da:	8b 45 08             	mov    0x8(%ebp),%eax
  8012dd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012e0:	6a 01                	push   $0x1
  8012e2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012e5:	50                   	push   %eax
  8012e6:	e8 e2 ed ff ff       	call   8000cd <sys_cputs>
}
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	c9                   	leave  
  8012ef:	c3                   	ret    

008012f0 <getchar>:

int
getchar(void)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8012f6:	6a 01                	push   $0x1
  8012f8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012fb:	50                   	push   %eax
  8012fc:	6a 00                	push   $0x0
  8012fe:	e8 87 f6 ff ff       	call   80098a <read>
	if (r < 0)
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	85 c0                	test   %eax,%eax
  801308:	78 0f                	js     801319 <getchar+0x29>
		return r;
	if (r < 1)
  80130a:	85 c0                	test   %eax,%eax
  80130c:	7e 06                	jle    801314 <getchar+0x24>
		return -E_EOF;
	return c;
  80130e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801312:	eb 05                	jmp    801319 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801314:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801319:	c9                   	leave  
  80131a:	c3                   	ret    

0080131b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801321:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801324:	50                   	push   %eax
  801325:	ff 75 08             	pushl  0x8(%ebp)
  801328:	e8 f7 f3 ff ff       	call   800724 <fd_lookup>
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	85 c0                	test   %eax,%eax
  801332:	78 11                	js     801345 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801334:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801337:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80133d:	39 10                	cmp    %edx,(%eax)
  80133f:	0f 94 c0             	sete   %al
  801342:	0f b6 c0             	movzbl %al,%eax
}
  801345:	c9                   	leave  
  801346:	c3                   	ret    

00801347 <opencons>:

int
opencons(void)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80134d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801350:	50                   	push   %eax
  801351:	e8 7f f3 ff ff       	call   8006d5 <fd_alloc>
  801356:	83 c4 10             	add    $0x10,%esp
		return r;
  801359:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80135b:	85 c0                	test   %eax,%eax
  80135d:	78 3e                	js     80139d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80135f:	83 ec 04             	sub    $0x4,%esp
  801362:	68 07 04 00 00       	push   $0x407
  801367:	ff 75 f4             	pushl  -0xc(%ebp)
  80136a:	6a 00                	push   $0x0
  80136c:	e8 18 ee ff ff       	call   800189 <sys_page_alloc>
  801371:	83 c4 10             	add    $0x10,%esp
		return r;
  801374:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801376:	85 c0                	test   %eax,%eax
  801378:	78 23                	js     80139d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80137a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801380:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801383:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801385:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801388:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80138f:	83 ec 0c             	sub    $0xc,%esp
  801392:	50                   	push   %eax
  801393:	e8 16 f3 ff ff       	call   8006ae <fd2num>
  801398:	89 c2                	mov    %eax,%edx
  80139a:	83 c4 10             	add    $0x10,%esp
}
  80139d:	89 d0                	mov    %edx,%eax
  80139f:	c9                   	leave  
  8013a0:	c3                   	ret    

008013a1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	56                   	push   %esi
  8013a5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013a6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013a9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013af:	e8 97 ed ff ff       	call   80014b <sys_getenvid>
  8013b4:	83 ec 0c             	sub    $0xc,%esp
  8013b7:	ff 75 0c             	pushl  0xc(%ebp)
  8013ba:	ff 75 08             	pushl  0x8(%ebp)
  8013bd:	56                   	push   %esi
  8013be:	50                   	push   %eax
  8013bf:	68 60 23 80 00       	push   $0x802360
  8013c4:	e8 b1 00 00 00       	call   80147a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013c9:	83 c4 18             	add    $0x18,%esp
  8013cc:	53                   	push   %ebx
  8013cd:	ff 75 10             	pushl  0x10(%ebp)
  8013d0:	e8 54 00 00 00       	call   801429 <vcprintf>
	cprintf("\n");
  8013d5:	c7 04 24 4b 23 80 00 	movl   $0x80234b,(%esp)
  8013dc:	e8 99 00 00 00       	call   80147a <cprintf>
  8013e1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013e4:	cc                   	int3   
  8013e5:	eb fd                	jmp    8013e4 <_panic+0x43>

008013e7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	53                   	push   %ebx
  8013eb:	83 ec 04             	sub    $0x4,%esp
  8013ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013f1:	8b 13                	mov    (%ebx),%edx
  8013f3:	8d 42 01             	lea    0x1(%edx),%eax
  8013f6:	89 03                	mov    %eax,(%ebx)
  8013f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013fb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013ff:	3d ff 00 00 00       	cmp    $0xff,%eax
  801404:	75 1a                	jne    801420 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801406:	83 ec 08             	sub    $0x8,%esp
  801409:	68 ff 00 00 00       	push   $0xff
  80140e:	8d 43 08             	lea    0x8(%ebx),%eax
  801411:	50                   	push   %eax
  801412:	e8 b6 ec ff ff       	call   8000cd <sys_cputs>
		b->idx = 0;
  801417:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80141d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801420:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801424:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801432:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801439:	00 00 00 
	b.cnt = 0;
  80143c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801443:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801446:	ff 75 0c             	pushl  0xc(%ebp)
  801449:	ff 75 08             	pushl  0x8(%ebp)
  80144c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801452:	50                   	push   %eax
  801453:	68 e7 13 80 00       	push   $0x8013e7
  801458:	e8 54 01 00 00       	call   8015b1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80145d:	83 c4 08             	add    $0x8,%esp
  801460:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801466:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80146c:	50                   	push   %eax
  80146d:	e8 5b ec ff ff       	call   8000cd <sys_cputs>

	return b.cnt;
}
  801472:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801478:	c9                   	leave  
  801479:	c3                   	ret    

0080147a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801480:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801483:	50                   	push   %eax
  801484:	ff 75 08             	pushl  0x8(%ebp)
  801487:	e8 9d ff ff ff       	call   801429 <vcprintf>
	va_end(ap);

	return cnt;
}
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	57                   	push   %edi
  801492:	56                   	push   %esi
  801493:	53                   	push   %ebx
  801494:	83 ec 1c             	sub    $0x1c,%esp
  801497:	89 c7                	mov    %eax,%edi
  801499:	89 d6                	mov    %edx,%esi
  80149b:	8b 45 08             	mov    0x8(%ebp),%eax
  80149e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014af:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014b2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014b5:	39 d3                	cmp    %edx,%ebx
  8014b7:	72 05                	jb     8014be <printnum+0x30>
  8014b9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014bc:	77 45                	ja     801503 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014be:	83 ec 0c             	sub    $0xc,%esp
  8014c1:	ff 75 18             	pushl  0x18(%ebp)
  8014c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014ca:	53                   	push   %ebx
  8014cb:	ff 75 10             	pushl  0x10(%ebp)
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8014d7:	ff 75 dc             	pushl  -0x24(%ebp)
  8014da:	ff 75 d8             	pushl  -0x28(%ebp)
  8014dd:	e8 4e 0a 00 00       	call   801f30 <__udivdi3>
  8014e2:	83 c4 18             	add    $0x18,%esp
  8014e5:	52                   	push   %edx
  8014e6:	50                   	push   %eax
  8014e7:	89 f2                	mov    %esi,%edx
  8014e9:	89 f8                	mov    %edi,%eax
  8014eb:	e8 9e ff ff ff       	call   80148e <printnum>
  8014f0:	83 c4 20             	add    $0x20,%esp
  8014f3:	eb 18                	jmp    80150d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014f5:	83 ec 08             	sub    $0x8,%esp
  8014f8:	56                   	push   %esi
  8014f9:	ff 75 18             	pushl  0x18(%ebp)
  8014fc:	ff d7                	call   *%edi
  8014fe:	83 c4 10             	add    $0x10,%esp
  801501:	eb 03                	jmp    801506 <printnum+0x78>
  801503:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801506:	83 eb 01             	sub    $0x1,%ebx
  801509:	85 db                	test   %ebx,%ebx
  80150b:	7f e8                	jg     8014f5 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80150d:	83 ec 08             	sub    $0x8,%esp
  801510:	56                   	push   %esi
  801511:	83 ec 04             	sub    $0x4,%esp
  801514:	ff 75 e4             	pushl  -0x1c(%ebp)
  801517:	ff 75 e0             	pushl  -0x20(%ebp)
  80151a:	ff 75 dc             	pushl  -0x24(%ebp)
  80151d:	ff 75 d8             	pushl  -0x28(%ebp)
  801520:	e8 3b 0b 00 00       	call   802060 <__umoddi3>
  801525:	83 c4 14             	add    $0x14,%esp
  801528:	0f be 80 83 23 80 00 	movsbl 0x802383(%eax),%eax
  80152f:	50                   	push   %eax
  801530:	ff d7                	call   *%edi
}
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801538:	5b                   	pop    %ebx
  801539:	5e                   	pop    %esi
  80153a:	5f                   	pop    %edi
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    

0080153d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801540:	83 fa 01             	cmp    $0x1,%edx
  801543:	7e 0e                	jle    801553 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801545:	8b 10                	mov    (%eax),%edx
  801547:	8d 4a 08             	lea    0x8(%edx),%ecx
  80154a:	89 08                	mov    %ecx,(%eax)
  80154c:	8b 02                	mov    (%edx),%eax
  80154e:	8b 52 04             	mov    0x4(%edx),%edx
  801551:	eb 22                	jmp    801575 <getuint+0x38>
	else if (lflag)
  801553:	85 d2                	test   %edx,%edx
  801555:	74 10                	je     801567 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801557:	8b 10                	mov    (%eax),%edx
  801559:	8d 4a 04             	lea    0x4(%edx),%ecx
  80155c:	89 08                	mov    %ecx,(%eax)
  80155e:	8b 02                	mov    (%edx),%eax
  801560:	ba 00 00 00 00       	mov    $0x0,%edx
  801565:	eb 0e                	jmp    801575 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801567:	8b 10                	mov    (%eax),%edx
  801569:	8d 4a 04             	lea    0x4(%edx),%ecx
  80156c:	89 08                	mov    %ecx,(%eax)
  80156e:	8b 02                	mov    (%edx),%eax
  801570:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801575:	5d                   	pop    %ebp
  801576:	c3                   	ret    

00801577 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80157d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801581:	8b 10                	mov    (%eax),%edx
  801583:	3b 50 04             	cmp    0x4(%eax),%edx
  801586:	73 0a                	jae    801592 <sprintputch+0x1b>
		*b->buf++ = ch;
  801588:	8d 4a 01             	lea    0x1(%edx),%ecx
  80158b:	89 08                	mov    %ecx,(%eax)
  80158d:	8b 45 08             	mov    0x8(%ebp),%eax
  801590:	88 02                	mov    %al,(%edx)
}
  801592:	5d                   	pop    %ebp
  801593:	c3                   	ret    

00801594 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80159a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80159d:	50                   	push   %eax
  80159e:	ff 75 10             	pushl  0x10(%ebp)
  8015a1:	ff 75 0c             	pushl  0xc(%ebp)
  8015a4:	ff 75 08             	pushl  0x8(%ebp)
  8015a7:	e8 05 00 00 00       	call   8015b1 <vprintfmt>
	va_end(ap);
}
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    

008015b1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	57                   	push   %edi
  8015b5:	56                   	push   %esi
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 2c             	sub    $0x2c,%esp
  8015ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8015bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015c0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015c3:	eb 12                	jmp    8015d7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	0f 84 89 03 00 00    	je     801956 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	53                   	push   %ebx
  8015d1:	50                   	push   %eax
  8015d2:	ff d6                	call   *%esi
  8015d4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015d7:	83 c7 01             	add    $0x1,%edi
  8015da:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015de:	83 f8 25             	cmp    $0x25,%eax
  8015e1:	75 e2                	jne    8015c5 <vprintfmt+0x14>
  8015e3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015e7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015ee:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8015f5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8015fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801601:	eb 07                	jmp    80160a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801603:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801606:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80160a:	8d 47 01             	lea    0x1(%edi),%eax
  80160d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801610:	0f b6 07             	movzbl (%edi),%eax
  801613:	0f b6 c8             	movzbl %al,%ecx
  801616:	83 e8 23             	sub    $0x23,%eax
  801619:	3c 55                	cmp    $0x55,%al
  80161b:	0f 87 1a 03 00 00    	ja     80193b <vprintfmt+0x38a>
  801621:	0f b6 c0             	movzbl %al,%eax
  801624:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  80162b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80162e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801632:	eb d6                	jmp    80160a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801634:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801637:	b8 00 00 00 00       	mov    $0x0,%eax
  80163c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80163f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801642:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801646:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801649:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80164c:	83 fa 09             	cmp    $0x9,%edx
  80164f:	77 39                	ja     80168a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801651:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801654:	eb e9                	jmp    80163f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801656:	8b 45 14             	mov    0x14(%ebp),%eax
  801659:	8d 48 04             	lea    0x4(%eax),%ecx
  80165c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80165f:	8b 00                	mov    (%eax),%eax
  801661:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801667:	eb 27                	jmp    801690 <vprintfmt+0xdf>
  801669:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80166c:	85 c0                	test   %eax,%eax
  80166e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801673:	0f 49 c8             	cmovns %eax,%ecx
  801676:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801679:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80167c:	eb 8c                	jmp    80160a <vprintfmt+0x59>
  80167e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801681:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801688:	eb 80                	jmp    80160a <vprintfmt+0x59>
  80168a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80168d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801690:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801694:	0f 89 70 ff ff ff    	jns    80160a <vprintfmt+0x59>
				width = precision, precision = -1;
  80169a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80169d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016a0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016a7:	e9 5e ff ff ff       	jmp    80160a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016ac:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016b2:	e9 53 ff ff ff       	jmp    80160a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ba:	8d 50 04             	lea    0x4(%eax),%edx
  8016bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	53                   	push   %ebx
  8016c4:	ff 30                	pushl  (%eax)
  8016c6:	ff d6                	call   *%esi
			break;
  8016c8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016ce:	e9 04 ff ff ff       	jmp    8015d7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d6:	8d 50 04             	lea    0x4(%eax),%edx
  8016d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8016dc:	8b 00                	mov    (%eax),%eax
  8016de:	99                   	cltd   
  8016df:	31 d0                	xor    %edx,%eax
  8016e1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016e3:	83 f8 0f             	cmp    $0xf,%eax
  8016e6:	7f 0b                	jg     8016f3 <vprintfmt+0x142>
  8016e8:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8016ef:	85 d2                	test   %edx,%edx
  8016f1:	75 18                	jne    80170b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8016f3:	50                   	push   %eax
  8016f4:	68 9b 23 80 00       	push   $0x80239b
  8016f9:	53                   	push   %ebx
  8016fa:	56                   	push   %esi
  8016fb:	e8 94 fe ff ff       	call   801594 <printfmt>
  801700:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801703:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801706:	e9 cc fe ff ff       	jmp    8015d7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80170b:	52                   	push   %edx
  80170c:	68 19 23 80 00       	push   $0x802319
  801711:	53                   	push   %ebx
  801712:	56                   	push   %esi
  801713:	e8 7c fe ff ff       	call   801594 <printfmt>
  801718:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80171b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80171e:	e9 b4 fe ff ff       	jmp    8015d7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801723:	8b 45 14             	mov    0x14(%ebp),%eax
  801726:	8d 50 04             	lea    0x4(%eax),%edx
  801729:	89 55 14             	mov    %edx,0x14(%ebp)
  80172c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80172e:	85 ff                	test   %edi,%edi
  801730:	b8 94 23 80 00       	mov    $0x802394,%eax
  801735:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801738:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80173c:	0f 8e 94 00 00 00    	jle    8017d6 <vprintfmt+0x225>
  801742:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801746:	0f 84 98 00 00 00    	je     8017e4 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80174c:	83 ec 08             	sub    $0x8,%esp
  80174f:	ff 75 d0             	pushl  -0x30(%ebp)
  801752:	57                   	push   %edi
  801753:	e8 86 02 00 00       	call   8019de <strnlen>
  801758:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80175b:	29 c1                	sub    %eax,%ecx
  80175d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801760:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801763:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801767:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80176a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80176d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80176f:	eb 0f                	jmp    801780 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801771:	83 ec 08             	sub    $0x8,%esp
  801774:	53                   	push   %ebx
  801775:	ff 75 e0             	pushl  -0x20(%ebp)
  801778:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80177a:	83 ef 01             	sub    $0x1,%edi
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	85 ff                	test   %edi,%edi
  801782:	7f ed                	jg     801771 <vprintfmt+0x1c0>
  801784:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801787:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80178a:	85 c9                	test   %ecx,%ecx
  80178c:	b8 00 00 00 00       	mov    $0x0,%eax
  801791:	0f 49 c1             	cmovns %ecx,%eax
  801794:	29 c1                	sub    %eax,%ecx
  801796:	89 75 08             	mov    %esi,0x8(%ebp)
  801799:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80179c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80179f:	89 cb                	mov    %ecx,%ebx
  8017a1:	eb 4d                	jmp    8017f0 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017a3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017a7:	74 1b                	je     8017c4 <vprintfmt+0x213>
  8017a9:	0f be c0             	movsbl %al,%eax
  8017ac:	83 e8 20             	sub    $0x20,%eax
  8017af:	83 f8 5e             	cmp    $0x5e,%eax
  8017b2:	76 10                	jbe    8017c4 <vprintfmt+0x213>
					putch('?', putdat);
  8017b4:	83 ec 08             	sub    $0x8,%esp
  8017b7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ba:	6a 3f                	push   $0x3f
  8017bc:	ff 55 08             	call   *0x8(%ebp)
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	eb 0d                	jmp    8017d1 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017c4:	83 ec 08             	sub    $0x8,%esp
  8017c7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ca:	52                   	push   %edx
  8017cb:	ff 55 08             	call   *0x8(%ebp)
  8017ce:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017d1:	83 eb 01             	sub    $0x1,%ebx
  8017d4:	eb 1a                	jmp    8017f0 <vprintfmt+0x23f>
  8017d6:	89 75 08             	mov    %esi,0x8(%ebp)
  8017d9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017df:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017e2:	eb 0c                	jmp    8017f0 <vprintfmt+0x23f>
  8017e4:	89 75 08             	mov    %esi,0x8(%ebp)
  8017e7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017ed:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017f0:	83 c7 01             	add    $0x1,%edi
  8017f3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017f7:	0f be d0             	movsbl %al,%edx
  8017fa:	85 d2                	test   %edx,%edx
  8017fc:	74 23                	je     801821 <vprintfmt+0x270>
  8017fe:	85 f6                	test   %esi,%esi
  801800:	78 a1                	js     8017a3 <vprintfmt+0x1f2>
  801802:	83 ee 01             	sub    $0x1,%esi
  801805:	79 9c                	jns    8017a3 <vprintfmt+0x1f2>
  801807:	89 df                	mov    %ebx,%edi
  801809:	8b 75 08             	mov    0x8(%ebp),%esi
  80180c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80180f:	eb 18                	jmp    801829 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801811:	83 ec 08             	sub    $0x8,%esp
  801814:	53                   	push   %ebx
  801815:	6a 20                	push   $0x20
  801817:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801819:	83 ef 01             	sub    $0x1,%edi
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	eb 08                	jmp    801829 <vprintfmt+0x278>
  801821:	89 df                	mov    %ebx,%edi
  801823:	8b 75 08             	mov    0x8(%ebp),%esi
  801826:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801829:	85 ff                	test   %edi,%edi
  80182b:	7f e4                	jg     801811 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801830:	e9 a2 fd ff ff       	jmp    8015d7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801835:	83 fa 01             	cmp    $0x1,%edx
  801838:	7e 16                	jle    801850 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80183a:	8b 45 14             	mov    0x14(%ebp),%eax
  80183d:	8d 50 08             	lea    0x8(%eax),%edx
  801840:	89 55 14             	mov    %edx,0x14(%ebp)
  801843:	8b 50 04             	mov    0x4(%eax),%edx
  801846:	8b 00                	mov    (%eax),%eax
  801848:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80184b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80184e:	eb 32                	jmp    801882 <vprintfmt+0x2d1>
	else if (lflag)
  801850:	85 d2                	test   %edx,%edx
  801852:	74 18                	je     80186c <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801854:	8b 45 14             	mov    0x14(%ebp),%eax
  801857:	8d 50 04             	lea    0x4(%eax),%edx
  80185a:	89 55 14             	mov    %edx,0x14(%ebp)
  80185d:	8b 00                	mov    (%eax),%eax
  80185f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801862:	89 c1                	mov    %eax,%ecx
  801864:	c1 f9 1f             	sar    $0x1f,%ecx
  801867:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80186a:	eb 16                	jmp    801882 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80186c:	8b 45 14             	mov    0x14(%ebp),%eax
  80186f:	8d 50 04             	lea    0x4(%eax),%edx
  801872:	89 55 14             	mov    %edx,0x14(%ebp)
  801875:	8b 00                	mov    (%eax),%eax
  801877:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80187a:	89 c1                	mov    %eax,%ecx
  80187c:	c1 f9 1f             	sar    $0x1f,%ecx
  80187f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801882:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801885:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801888:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80188d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801891:	79 74                	jns    801907 <vprintfmt+0x356>
				putch('-', putdat);
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	53                   	push   %ebx
  801897:	6a 2d                	push   $0x2d
  801899:	ff d6                	call   *%esi
				num = -(long long) num;
  80189b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80189e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8018a1:	f7 d8                	neg    %eax
  8018a3:	83 d2 00             	adc    $0x0,%edx
  8018a6:	f7 da                	neg    %edx
  8018a8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018ab:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018b0:	eb 55                	jmp    801907 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8018b5:	e8 83 fc ff ff       	call   80153d <getuint>
			base = 10;
  8018ba:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018bf:	eb 46                	jmp    801907 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8018c4:	e8 74 fc ff ff       	call   80153d <getuint>
			base = 8;
  8018c9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018ce:	eb 37                	jmp    801907 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018d0:	83 ec 08             	sub    $0x8,%esp
  8018d3:	53                   	push   %ebx
  8018d4:	6a 30                	push   $0x30
  8018d6:	ff d6                	call   *%esi
			putch('x', putdat);
  8018d8:	83 c4 08             	add    $0x8,%esp
  8018db:	53                   	push   %ebx
  8018dc:	6a 78                	push   $0x78
  8018de:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e3:	8d 50 04             	lea    0x4(%eax),%edx
  8018e6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018e9:	8b 00                	mov    (%eax),%eax
  8018eb:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018f0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8018f3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8018f8:	eb 0d                	jmp    801907 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8018fd:	e8 3b fc ff ff       	call   80153d <getuint>
			base = 16;
  801902:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801907:	83 ec 0c             	sub    $0xc,%esp
  80190a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80190e:	57                   	push   %edi
  80190f:	ff 75 e0             	pushl  -0x20(%ebp)
  801912:	51                   	push   %ecx
  801913:	52                   	push   %edx
  801914:	50                   	push   %eax
  801915:	89 da                	mov    %ebx,%edx
  801917:	89 f0                	mov    %esi,%eax
  801919:	e8 70 fb ff ff       	call   80148e <printnum>
			break;
  80191e:	83 c4 20             	add    $0x20,%esp
  801921:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801924:	e9 ae fc ff ff       	jmp    8015d7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801929:	83 ec 08             	sub    $0x8,%esp
  80192c:	53                   	push   %ebx
  80192d:	51                   	push   %ecx
  80192e:	ff d6                	call   *%esi
			break;
  801930:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801933:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801936:	e9 9c fc ff ff       	jmp    8015d7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80193b:	83 ec 08             	sub    $0x8,%esp
  80193e:	53                   	push   %ebx
  80193f:	6a 25                	push   $0x25
  801941:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	eb 03                	jmp    80194b <vprintfmt+0x39a>
  801948:	83 ef 01             	sub    $0x1,%edi
  80194b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80194f:	75 f7                	jne    801948 <vprintfmt+0x397>
  801951:	e9 81 fc ff ff       	jmp    8015d7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801956:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801959:	5b                   	pop    %ebx
  80195a:	5e                   	pop    %esi
  80195b:	5f                   	pop    %edi
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	83 ec 18             	sub    $0x18,%esp
  801964:	8b 45 08             	mov    0x8(%ebp),%eax
  801967:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80196a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80196d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801971:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801974:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80197b:	85 c0                	test   %eax,%eax
  80197d:	74 26                	je     8019a5 <vsnprintf+0x47>
  80197f:	85 d2                	test   %edx,%edx
  801981:	7e 22                	jle    8019a5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801983:	ff 75 14             	pushl  0x14(%ebp)
  801986:	ff 75 10             	pushl  0x10(%ebp)
  801989:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80198c:	50                   	push   %eax
  80198d:	68 77 15 80 00       	push   $0x801577
  801992:	e8 1a fc ff ff       	call   8015b1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801997:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80199a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80199d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a0:	83 c4 10             	add    $0x10,%esp
  8019a3:	eb 05                	jmp    8019aa <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019b2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019b5:	50                   	push   %eax
  8019b6:	ff 75 10             	pushl  0x10(%ebp)
  8019b9:	ff 75 0c             	pushl  0xc(%ebp)
  8019bc:	ff 75 08             	pushl  0x8(%ebp)
  8019bf:	e8 9a ff ff ff       	call   80195e <vsnprintf>
	va_end(ap);

	return rc;
}
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d1:	eb 03                	jmp    8019d6 <strlen+0x10>
		n++;
  8019d3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019da:	75 f7                	jne    8019d3 <strlen+0xd>
		n++;
	return n;
}
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ec:	eb 03                	jmp    8019f1 <strnlen+0x13>
		n++;
  8019ee:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019f1:	39 c2                	cmp    %eax,%edx
  8019f3:	74 08                	je     8019fd <strnlen+0x1f>
  8019f5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8019f9:	75 f3                	jne    8019ee <strnlen+0x10>
  8019fb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8019fd:	5d                   	pop    %ebp
  8019fe:	c3                   	ret    

008019ff <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	53                   	push   %ebx
  801a03:	8b 45 08             	mov    0x8(%ebp),%eax
  801a06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a09:	89 c2                	mov    %eax,%edx
  801a0b:	83 c2 01             	add    $0x1,%edx
  801a0e:	83 c1 01             	add    $0x1,%ecx
  801a11:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a15:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a18:	84 db                	test   %bl,%bl
  801a1a:	75 ef                	jne    801a0b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a1c:	5b                   	pop    %ebx
  801a1d:	5d                   	pop    %ebp
  801a1e:	c3                   	ret    

00801a1f <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	53                   	push   %ebx
  801a23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a26:	53                   	push   %ebx
  801a27:	e8 9a ff ff ff       	call   8019c6 <strlen>
  801a2c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a2f:	ff 75 0c             	pushl  0xc(%ebp)
  801a32:	01 d8                	add    %ebx,%eax
  801a34:	50                   	push   %eax
  801a35:	e8 c5 ff ff ff       	call   8019ff <strcpy>
	return dst;
}
  801a3a:	89 d8                	mov    %ebx,%eax
  801a3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	56                   	push   %esi
  801a45:	53                   	push   %ebx
  801a46:	8b 75 08             	mov    0x8(%ebp),%esi
  801a49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a4c:	89 f3                	mov    %esi,%ebx
  801a4e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a51:	89 f2                	mov    %esi,%edx
  801a53:	eb 0f                	jmp    801a64 <strncpy+0x23>
		*dst++ = *src;
  801a55:	83 c2 01             	add    $0x1,%edx
  801a58:	0f b6 01             	movzbl (%ecx),%eax
  801a5b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a5e:	80 39 01             	cmpb   $0x1,(%ecx)
  801a61:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a64:	39 da                	cmp    %ebx,%edx
  801a66:	75 ed                	jne    801a55 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a68:	89 f0                	mov    %esi,%eax
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	56                   	push   %esi
  801a72:	53                   	push   %ebx
  801a73:	8b 75 08             	mov    0x8(%ebp),%esi
  801a76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a79:	8b 55 10             	mov    0x10(%ebp),%edx
  801a7c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a7e:	85 d2                	test   %edx,%edx
  801a80:	74 21                	je     801aa3 <strlcpy+0x35>
  801a82:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a86:	89 f2                	mov    %esi,%edx
  801a88:	eb 09                	jmp    801a93 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a8a:	83 c2 01             	add    $0x1,%edx
  801a8d:	83 c1 01             	add    $0x1,%ecx
  801a90:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a93:	39 c2                	cmp    %eax,%edx
  801a95:	74 09                	je     801aa0 <strlcpy+0x32>
  801a97:	0f b6 19             	movzbl (%ecx),%ebx
  801a9a:	84 db                	test   %bl,%bl
  801a9c:	75 ec                	jne    801a8a <strlcpy+0x1c>
  801a9e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801aa0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801aa3:	29 f0                	sub    %esi,%eax
}
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    

00801aa9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801aa9:	55                   	push   %ebp
  801aaa:	89 e5                	mov    %esp,%ebp
  801aac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801ab2:	eb 06                	jmp    801aba <strcmp+0x11>
		p++, q++;
  801ab4:	83 c1 01             	add    $0x1,%ecx
  801ab7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801aba:	0f b6 01             	movzbl (%ecx),%eax
  801abd:	84 c0                	test   %al,%al
  801abf:	74 04                	je     801ac5 <strcmp+0x1c>
  801ac1:	3a 02                	cmp    (%edx),%al
  801ac3:	74 ef                	je     801ab4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ac5:	0f b6 c0             	movzbl %al,%eax
  801ac8:	0f b6 12             	movzbl (%edx),%edx
  801acb:	29 d0                	sub    %edx,%eax
}
  801acd:	5d                   	pop    %ebp
  801ace:	c3                   	ret    

00801acf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	53                   	push   %ebx
  801ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ad9:	89 c3                	mov    %eax,%ebx
  801adb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ade:	eb 06                	jmp    801ae6 <strncmp+0x17>
		n--, p++, q++;
  801ae0:	83 c0 01             	add    $0x1,%eax
  801ae3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ae6:	39 d8                	cmp    %ebx,%eax
  801ae8:	74 15                	je     801aff <strncmp+0x30>
  801aea:	0f b6 08             	movzbl (%eax),%ecx
  801aed:	84 c9                	test   %cl,%cl
  801aef:	74 04                	je     801af5 <strncmp+0x26>
  801af1:	3a 0a                	cmp    (%edx),%cl
  801af3:	74 eb                	je     801ae0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801af5:	0f b6 00             	movzbl (%eax),%eax
  801af8:	0f b6 12             	movzbl (%edx),%edx
  801afb:	29 d0                	sub    %edx,%eax
  801afd:	eb 05                	jmp    801b04 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801aff:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b04:	5b                   	pop    %ebx
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    

00801b07 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b11:	eb 07                	jmp    801b1a <strchr+0x13>
		if (*s == c)
  801b13:	38 ca                	cmp    %cl,%dl
  801b15:	74 0f                	je     801b26 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b17:	83 c0 01             	add    $0x1,%eax
  801b1a:	0f b6 10             	movzbl (%eax),%edx
  801b1d:	84 d2                	test   %dl,%dl
  801b1f:	75 f2                	jne    801b13 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    

00801b28 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b32:	eb 03                	jmp    801b37 <strfind+0xf>
  801b34:	83 c0 01             	add    $0x1,%eax
  801b37:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b3a:	38 ca                	cmp    %cl,%dl
  801b3c:	74 04                	je     801b42 <strfind+0x1a>
  801b3e:	84 d2                	test   %dl,%dl
  801b40:	75 f2                	jne    801b34 <strfind+0xc>
			break;
	return (char *) s;
}
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	57                   	push   %edi
  801b48:	56                   	push   %esi
  801b49:	53                   	push   %ebx
  801b4a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b50:	85 c9                	test   %ecx,%ecx
  801b52:	74 36                	je     801b8a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b5a:	75 28                	jne    801b84 <memset+0x40>
  801b5c:	f6 c1 03             	test   $0x3,%cl
  801b5f:	75 23                	jne    801b84 <memset+0x40>
		c &= 0xFF;
  801b61:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b65:	89 d3                	mov    %edx,%ebx
  801b67:	c1 e3 08             	shl    $0x8,%ebx
  801b6a:	89 d6                	mov    %edx,%esi
  801b6c:	c1 e6 18             	shl    $0x18,%esi
  801b6f:	89 d0                	mov    %edx,%eax
  801b71:	c1 e0 10             	shl    $0x10,%eax
  801b74:	09 f0                	or     %esi,%eax
  801b76:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b78:	89 d8                	mov    %ebx,%eax
  801b7a:	09 d0                	or     %edx,%eax
  801b7c:	c1 e9 02             	shr    $0x2,%ecx
  801b7f:	fc                   	cld    
  801b80:	f3 ab                	rep stos %eax,%es:(%edi)
  801b82:	eb 06                	jmp    801b8a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b87:	fc                   	cld    
  801b88:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b8a:	89 f8                	mov    %edi,%eax
  801b8c:	5b                   	pop    %ebx
  801b8d:	5e                   	pop    %esi
  801b8e:	5f                   	pop    %edi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	57                   	push   %edi
  801b95:	56                   	push   %esi
  801b96:	8b 45 08             	mov    0x8(%ebp),%eax
  801b99:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b9f:	39 c6                	cmp    %eax,%esi
  801ba1:	73 35                	jae    801bd8 <memmove+0x47>
  801ba3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ba6:	39 d0                	cmp    %edx,%eax
  801ba8:	73 2e                	jae    801bd8 <memmove+0x47>
		s += n;
		d += n;
  801baa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bad:	89 d6                	mov    %edx,%esi
  801baf:	09 fe                	or     %edi,%esi
  801bb1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801bb7:	75 13                	jne    801bcc <memmove+0x3b>
  801bb9:	f6 c1 03             	test   $0x3,%cl
  801bbc:	75 0e                	jne    801bcc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bbe:	83 ef 04             	sub    $0x4,%edi
  801bc1:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bc4:	c1 e9 02             	shr    $0x2,%ecx
  801bc7:	fd                   	std    
  801bc8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bca:	eb 09                	jmp    801bd5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bcc:	83 ef 01             	sub    $0x1,%edi
  801bcf:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bd2:	fd                   	std    
  801bd3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bd5:	fc                   	cld    
  801bd6:	eb 1d                	jmp    801bf5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bd8:	89 f2                	mov    %esi,%edx
  801bda:	09 c2                	or     %eax,%edx
  801bdc:	f6 c2 03             	test   $0x3,%dl
  801bdf:	75 0f                	jne    801bf0 <memmove+0x5f>
  801be1:	f6 c1 03             	test   $0x3,%cl
  801be4:	75 0a                	jne    801bf0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801be6:	c1 e9 02             	shr    $0x2,%ecx
  801be9:	89 c7                	mov    %eax,%edi
  801beb:	fc                   	cld    
  801bec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bee:	eb 05                	jmp    801bf5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801bf0:	89 c7                	mov    %eax,%edi
  801bf2:	fc                   	cld    
  801bf3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801bf5:	5e                   	pop    %esi
  801bf6:	5f                   	pop    %edi
  801bf7:	5d                   	pop    %ebp
  801bf8:	c3                   	ret    

00801bf9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801bfc:	ff 75 10             	pushl  0x10(%ebp)
  801bff:	ff 75 0c             	pushl  0xc(%ebp)
  801c02:	ff 75 08             	pushl  0x8(%ebp)
  801c05:	e8 87 ff ff ff       	call   801b91 <memmove>
}
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	56                   	push   %esi
  801c10:	53                   	push   %ebx
  801c11:	8b 45 08             	mov    0x8(%ebp),%eax
  801c14:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c17:	89 c6                	mov    %eax,%esi
  801c19:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c1c:	eb 1a                	jmp    801c38 <memcmp+0x2c>
		if (*s1 != *s2)
  801c1e:	0f b6 08             	movzbl (%eax),%ecx
  801c21:	0f b6 1a             	movzbl (%edx),%ebx
  801c24:	38 d9                	cmp    %bl,%cl
  801c26:	74 0a                	je     801c32 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c28:	0f b6 c1             	movzbl %cl,%eax
  801c2b:	0f b6 db             	movzbl %bl,%ebx
  801c2e:	29 d8                	sub    %ebx,%eax
  801c30:	eb 0f                	jmp    801c41 <memcmp+0x35>
		s1++, s2++;
  801c32:	83 c0 01             	add    $0x1,%eax
  801c35:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c38:	39 f0                	cmp    %esi,%eax
  801c3a:	75 e2                	jne    801c1e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	53                   	push   %ebx
  801c49:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c4c:	89 c1                	mov    %eax,%ecx
  801c4e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c51:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c55:	eb 0a                	jmp    801c61 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c57:	0f b6 10             	movzbl (%eax),%edx
  801c5a:	39 da                	cmp    %ebx,%edx
  801c5c:	74 07                	je     801c65 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c5e:	83 c0 01             	add    $0x1,%eax
  801c61:	39 c8                	cmp    %ecx,%eax
  801c63:	72 f2                	jb     801c57 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c65:	5b                   	pop    %ebx
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    

00801c68 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	57                   	push   %edi
  801c6c:	56                   	push   %esi
  801c6d:	53                   	push   %ebx
  801c6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c74:	eb 03                	jmp    801c79 <strtol+0x11>
		s++;
  801c76:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c79:	0f b6 01             	movzbl (%ecx),%eax
  801c7c:	3c 20                	cmp    $0x20,%al
  801c7e:	74 f6                	je     801c76 <strtol+0xe>
  801c80:	3c 09                	cmp    $0x9,%al
  801c82:	74 f2                	je     801c76 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c84:	3c 2b                	cmp    $0x2b,%al
  801c86:	75 0a                	jne    801c92 <strtol+0x2a>
		s++;
  801c88:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c8b:	bf 00 00 00 00       	mov    $0x0,%edi
  801c90:	eb 11                	jmp    801ca3 <strtol+0x3b>
  801c92:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c97:	3c 2d                	cmp    $0x2d,%al
  801c99:	75 08                	jne    801ca3 <strtol+0x3b>
		s++, neg = 1;
  801c9b:	83 c1 01             	add    $0x1,%ecx
  801c9e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ca3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ca9:	75 15                	jne    801cc0 <strtol+0x58>
  801cab:	80 39 30             	cmpb   $0x30,(%ecx)
  801cae:	75 10                	jne    801cc0 <strtol+0x58>
  801cb0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801cb4:	75 7c                	jne    801d32 <strtol+0xca>
		s += 2, base = 16;
  801cb6:	83 c1 02             	add    $0x2,%ecx
  801cb9:	bb 10 00 00 00       	mov    $0x10,%ebx
  801cbe:	eb 16                	jmp    801cd6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801cc0:	85 db                	test   %ebx,%ebx
  801cc2:	75 12                	jne    801cd6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cc4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cc9:	80 39 30             	cmpb   $0x30,(%ecx)
  801ccc:	75 08                	jne    801cd6 <strtol+0x6e>
		s++, base = 8;
  801cce:	83 c1 01             	add    $0x1,%ecx
  801cd1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cde:	0f b6 11             	movzbl (%ecx),%edx
  801ce1:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ce4:	89 f3                	mov    %esi,%ebx
  801ce6:	80 fb 09             	cmp    $0x9,%bl
  801ce9:	77 08                	ja     801cf3 <strtol+0x8b>
			dig = *s - '0';
  801ceb:	0f be d2             	movsbl %dl,%edx
  801cee:	83 ea 30             	sub    $0x30,%edx
  801cf1:	eb 22                	jmp    801d15 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801cf3:	8d 72 9f             	lea    -0x61(%edx),%esi
  801cf6:	89 f3                	mov    %esi,%ebx
  801cf8:	80 fb 19             	cmp    $0x19,%bl
  801cfb:	77 08                	ja     801d05 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801cfd:	0f be d2             	movsbl %dl,%edx
  801d00:	83 ea 57             	sub    $0x57,%edx
  801d03:	eb 10                	jmp    801d15 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d05:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d08:	89 f3                	mov    %esi,%ebx
  801d0a:	80 fb 19             	cmp    $0x19,%bl
  801d0d:	77 16                	ja     801d25 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d0f:	0f be d2             	movsbl %dl,%edx
  801d12:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d15:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d18:	7d 0b                	jge    801d25 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d1a:	83 c1 01             	add    $0x1,%ecx
  801d1d:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d21:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d23:	eb b9                	jmp    801cde <strtol+0x76>

	if (endptr)
  801d25:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d29:	74 0d                	je     801d38 <strtol+0xd0>
		*endptr = (char *) s;
  801d2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d2e:	89 0e                	mov    %ecx,(%esi)
  801d30:	eb 06                	jmp    801d38 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d32:	85 db                	test   %ebx,%ebx
  801d34:	74 98                	je     801cce <strtol+0x66>
  801d36:	eb 9e                	jmp    801cd6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d38:	89 c2                	mov    %eax,%edx
  801d3a:	f7 da                	neg    %edx
  801d3c:	85 ff                	test   %edi,%edi
  801d3e:	0f 45 c2             	cmovne %edx,%eax
}
  801d41:	5b                   	pop    %ebx
  801d42:	5e                   	pop    %esi
  801d43:	5f                   	pop    %edi
  801d44:	5d                   	pop    %ebp
  801d45:	c3                   	ret    

00801d46 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d4c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d53:	75 2a                	jne    801d7f <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d55:	83 ec 04             	sub    $0x4,%esp
  801d58:	6a 07                	push   $0x7
  801d5a:	68 00 f0 bf ee       	push   $0xeebff000
  801d5f:	6a 00                	push   $0x0
  801d61:	e8 23 e4 ff ff       	call   800189 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d66:	83 c4 10             	add    $0x10,%esp
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	79 12                	jns    801d7f <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d6d:	50                   	push   %eax
  801d6e:	68 80 26 80 00       	push   $0x802680
  801d73:	6a 23                	push   $0x23
  801d75:	68 84 26 80 00       	push   $0x802684
  801d7a:	e8 22 f6 ff ff       	call   8013a1 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d82:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d87:	83 ec 08             	sub    $0x8,%esp
  801d8a:	68 b1 1d 80 00       	push   $0x801db1
  801d8f:	6a 00                	push   $0x0
  801d91:	e8 3e e5 ff ff       	call   8002d4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d96:	83 c4 10             	add    $0x10,%esp
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	79 12                	jns    801daf <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801d9d:	50                   	push   %eax
  801d9e:	68 80 26 80 00       	push   $0x802680
  801da3:	6a 2c                	push   $0x2c
  801da5:	68 84 26 80 00       	push   $0x802684
  801daa:	e8 f2 f5 ff ff       	call   8013a1 <_panic>
	}
}
  801daf:	c9                   	leave  
  801db0:	c3                   	ret    

00801db1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801db1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801db2:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801db7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801db9:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dbc:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dc0:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dc5:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dc9:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dcb:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dce:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dcf:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dd2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dd3:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dd4:	c3                   	ret    

00801dd5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	56                   	push   %esi
  801dd9:	53                   	push   %ebx
  801dda:	8b 75 08             	mov    0x8(%ebp),%esi
  801ddd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801de3:	85 c0                	test   %eax,%eax
  801de5:	75 12                	jne    801df9 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801de7:	83 ec 0c             	sub    $0xc,%esp
  801dea:	68 00 00 c0 ee       	push   $0xeec00000
  801def:	e8 45 e5 ff ff       	call   800339 <sys_ipc_recv>
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	eb 0c                	jmp    801e05 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801df9:	83 ec 0c             	sub    $0xc,%esp
  801dfc:	50                   	push   %eax
  801dfd:	e8 37 e5 ff ff       	call   800339 <sys_ipc_recv>
  801e02:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e05:	85 f6                	test   %esi,%esi
  801e07:	0f 95 c1             	setne  %cl
  801e0a:	85 db                	test   %ebx,%ebx
  801e0c:	0f 95 c2             	setne  %dl
  801e0f:	84 d1                	test   %dl,%cl
  801e11:	74 09                	je     801e1c <ipc_recv+0x47>
  801e13:	89 c2                	mov    %eax,%edx
  801e15:	c1 ea 1f             	shr    $0x1f,%edx
  801e18:	84 d2                	test   %dl,%dl
  801e1a:	75 2d                	jne    801e49 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e1c:	85 f6                	test   %esi,%esi
  801e1e:	74 0d                	je     801e2d <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e20:	a1 04 40 80 00       	mov    0x804004,%eax
  801e25:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e2b:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e2d:	85 db                	test   %ebx,%ebx
  801e2f:	74 0d                	je     801e3e <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e31:	a1 04 40 80 00       	mov    0x804004,%eax
  801e36:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e3c:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e3e:	a1 04 40 80 00       	mov    0x804004,%eax
  801e43:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4c:	5b                   	pop    %ebx
  801e4d:	5e                   	pop    %esi
  801e4e:	5d                   	pop    %ebp
  801e4f:	c3                   	ret    

00801e50 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	57                   	push   %edi
  801e54:	56                   	push   %esi
  801e55:	53                   	push   %ebx
  801e56:	83 ec 0c             	sub    $0xc,%esp
  801e59:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e62:	85 db                	test   %ebx,%ebx
  801e64:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e69:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e6c:	ff 75 14             	pushl  0x14(%ebp)
  801e6f:	53                   	push   %ebx
  801e70:	56                   	push   %esi
  801e71:	57                   	push   %edi
  801e72:	e8 9f e4 ff ff       	call   800316 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e77:	89 c2                	mov    %eax,%edx
  801e79:	c1 ea 1f             	shr    $0x1f,%edx
  801e7c:	83 c4 10             	add    $0x10,%esp
  801e7f:	84 d2                	test   %dl,%dl
  801e81:	74 17                	je     801e9a <ipc_send+0x4a>
  801e83:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e86:	74 12                	je     801e9a <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e88:	50                   	push   %eax
  801e89:	68 92 26 80 00       	push   $0x802692
  801e8e:	6a 47                	push   $0x47
  801e90:	68 a0 26 80 00       	push   $0x8026a0
  801e95:	e8 07 f5 ff ff       	call   8013a1 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e9a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e9d:	75 07                	jne    801ea6 <ipc_send+0x56>
			sys_yield();
  801e9f:	e8 c6 e2 ff ff       	call   80016a <sys_yield>
  801ea4:	eb c6                	jmp    801e6c <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	75 c2                	jne    801e6c <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801eaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ead:	5b                   	pop    %ebx
  801eae:	5e                   	pop    %esi
  801eaf:	5f                   	pop    %edi
  801eb0:	5d                   	pop    %ebp
  801eb1:	c3                   	ret    

00801eb2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eb8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ebd:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801ec3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ec9:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ecf:	39 ca                	cmp    %ecx,%edx
  801ed1:	75 10                	jne    801ee3 <ipc_find_env+0x31>
			return envs[i].env_id;
  801ed3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801ed9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ede:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ee1:	eb 0f                	jmp    801ef2 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ee3:	83 c0 01             	add    $0x1,%eax
  801ee6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801eeb:	75 d0                	jne    801ebd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801eed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ef2:	5d                   	pop    %ebp
  801ef3:	c3                   	ret    

00801ef4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ef4:	55                   	push   %ebp
  801ef5:	89 e5                	mov    %esp,%ebp
  801ef7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801efa:	89 d0                	mov    %edx,%eax
  801efc:	c1 e8 16             	shr    $0x16,%eax
  801eff:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f06:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f0b:	f6 c1 01             	test   $0x1,%cl
  801f0e:	74 1d                	je     801f2d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f10:	c1 ea 0c             	shr    $0xc,%edx
  801f13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f1a:	f6 c2 01             	test   $0x1,%dl
  801f1d:	74 0e                	je     801f2d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f1f:	c1 ea 0c             	shr    $0xc,%edx
  801f22:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f29:	ef 
  801f2a:	0f b7 c0             	movzwl %ax,%eax
}
  801f2d:	5d                   	pop    %ebp
  801f2e:	c3                   	ret    
  801f2f:	90                   	nop

00801f30 <__udivdi3>:
  801f30:	55                   	push   %ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	83 ec 1c             	sub    $0x1c,%esp
  801f37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f47:	85 f6                	test   %esi,%esi
  801f49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f4d:	89 ca                	mov    %ecx,%edx
  801f4f:	89 f8                	mov    %edi,%eax
  801f51:	75 3d                	jne    801f90 <__udivdi3+0x60>
  801f53:	39 cf                	cmp    %ecx,%edi
  801f55:	0f 87 c5 00 00 00    	ja     802020 <__udivdi3+0xf0>
  801f5b:	85 ff                	test   %edi,%edi
  801f5d:	89 fd                	mov    %edi,%ebp
  801f5f:	75 0b                	jne    801f6c <__udivdi3+0x3c>
  801f61:	b8 01 00 00 00       	mov    $0x1,%eax
  801f66:	31 d2                	xor    %edx,%edx
  801f68:	f7 f7                	div    %edi
  801f6a:	89 c5                	mov    %eax,%ebp
  801f6c:	89 c8                	mov    %ecx,%eax
  801f6e:	31 d2                	xor    %edx,%edx
  801f70:	f7 f5                	div    %ebp
  801f72:	89 c1                	mov    %eax,%ecx
  801f74:	89 d8                	mov    %ebx,%eax
  801f76:	89 cf                	mov    %ecx,%edi
  801f78:	f7 f5                	div    %ebp
  801f7a:	89 c3                	mov    %eax,%ebx
  801f7c:	89 d8                	mov    %ebx,%eax
  801f7e:	89 fa                	mov    %edi,%edx
  801f80:	83 c4 1c             	add    $0x1c,%esp
  801f83:	5b                   	pop    %ebx
  801f84:	5e                   	pop    %esi
  801f85:	5f                   	pop    %edi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    
  801f88:	90                   	nop
  801f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f90:	39 ce                	cmp    %ecx,%esi
  801f92:	77 74                	ja     802008 <__udivdi3+0xd8>
  801f94:	0f bd fe             	bsr    %esi,%edi
  801f97:	83 f7 1f             	xor    $0x1f,%edi
  801f9a:	0f 84 98 00 00 00    	je     802038 <__udivdi3+0x108>
  801fa0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fa5:	89 f9                	mov    %edi,%ecx
  801fa7:	89 c5                	mov    %eax,%ebp
  801fa9:	29 fb                	sub    %edi,%ebx
  801fab:	d3 e6                	shl    %cl,%esi
  801fad:	89 d9                	mov    %ebx,%ecx
  801faf:	d3 ed                	shr    %cl,%ebp
  801fb1:	89 f9                	mov    %edi,%ecx
  801fb3:	d3 e0                	shl    %cl,%eax
  801fb5:	09 ee                	or     %ebp,%esi
  801fb7:	89 d9                	mov    %ebx,%ecx
  801fb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fbd:	89 d5                	mov    %edx,%ebp
  801fbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fc3:	d3 ed                	shr    %cl,%ebp
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	d3 e2                	shl    %cl,%edx
  801fc9:	89 d9                	mov    %ebx,%ecx
  801fcb:	d3 e8                	shr    %cl,%eax
  801fcd:	09 c2                	or     %eax,%edx
  801fcf:	89 d0                	mov    %edx,%eax
  801fd1:	89 ea                	mov    %ebp,%edx
  801fd3:	f7 f6                	div    %esi
  801fd5:	89 d5                	mov    %edx,%ebp
  801fd7:	89 c3                	mov    %eax,%ebx
  801fd9:	f7 64 24 0c          	mull   0xc(%esp)
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	72 10                	jb     801ff1 <__udivdi3+0xc1>
  801fe1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	d3 e6                	shl    %cl,%esi
  801fe9:	39 c6                	cmp    %eax,%esi
  801feb:	73 07                	jae    801ff4 <__udivdi3+0xc4>
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	75 03                	jne    801ff4 <__udivdi3+0xc4>
  801ff1:	83 eb 01             	sub    $0x1,%ebx
  801ff4:	31 ff                	xor    %edi,%edi
  801ff6:	89 d8                	mov    %ebx,%eax
  801ff8:	89 fa                	mov    %edi,%edx
  801ffa:	83 c4 1c             	add    $0x1c,%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    
  802002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802008:	31 ff                	xor    %edi,%edi
  80200a:	31 db                	xor    %ebx,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	89 d8                	mov    %ebx,%eax
  802022:	f7 f7                	div    %edi
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 c3                	mov    %eax,%ebx
  802028:	89 d8                	mov    %ebx,%eax
  80202a:	89 fa                	mov    %edi,%edx
  80202c:	83 c4 1c             	add    $0x1c,%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    
  802034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802038:	39 ce                	cmp    %ecx,%esi
  80203a:	72 0c                	jb     802048 <__udivdi3+0x118>
  80203c:	31 db                	xor    %ebx,%ebx
  80203e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802042:	0f 87 34 ff ff ff    	ja     801f7c <__udivdi3+0x4c>
  802048:	bb 01 00 00 00       	mov    $0x1,%ebx
  80204d:	e9 2a ff ff ff       	jmp    801f7c <__udivdi3+0x4c>
  802052:	66 90                	xchg   %ax,%ax
  802054:	66 90                	xchg   %ax,%ax
  802056:	66 90                	xchg   %ax,%ax
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__umoddi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80206b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80206f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 d2                	test   %edx,%edx
  802079:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80207d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802081:	89 f3                	mov    %esi,%ebx
  802083:	89 3c 24             	mov    %edi,(%esp)
  802086:	89 74 24 04          	mov    %esi,0x4(%esp)
  80208a:	75 1c                	jne    8020a8 <__umoddi3+0x48>
  80208c:	39 f7                	cmp    %esi,%edi
  80208e:	76 50                	jbe    8020e0 <__umoddi3+0x80>
  802090:	89 c8                	mov    %ecx,%eax
  802092:	89 f2                	mov    %esi,%edx
  802094:	f7 f7                	div    %edi
  802096:	89 d0                	mov    %edx,%eax
  802098:	31 d2                	xor    %edx,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	39 f2                	cmp    %esi,%edx
  8020aa:	89 d0                	mov    %edx,%eax
  8020ac:	77 52                	ja     802100 <__umoddi3+0xa0>
  8020ae:	0f bd ea             	bsr    %edx,%ebp
  8020b1:	83 f5 1f             	xor    $0x1f,%ebp
  8020b4:	75 5a                	jne    802110 <__umoddi3+0xb0>
  8020b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ba:	0f 82 e0 00 00 00    	jb     8021a0 <__umoddi3+0x140>
  8020c0:	39 0c 24             	cmp    %ecx,(%esp)
  8020c3:	0f 86 d7 00 00 00    	jbe    8021a0 <__umoddi3+0x140>
  8020c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020d1:	83 c4 1c             	add    $0x1c,%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5e                   	pop    %esi
  8020d6:	5f                   	pop    %edi
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	85 ff                	test   %edi,%edi
  8020e2:	89 fd                	mov    %edi,%ebp
  8020e4:	75 0b                	jne    8020f1 <__umoddi3+0x91>
  8020e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  8020ed:	f7 f7                	div    %edi
  8020ef:	89 c5                	mov    %eax,%ebp
  8020f1:	89 f0                	mov    %esi,%eax
  8020f3:	31 d2                	xor    %edx,%edx
  8020f5:	f7 f5                	div    %ebp
  8020f7:	89 c8                	mov    %ecx,%eax
  8020f9:	f7 f5                	div    %ebp
  8020fb:	89 d0                	mov    %edx,%eax
  8020fd:	eb 99                	jmp    802098 <__umoddi3+0x38>
  8020ff:	90                   	nop
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	83 c4 1c             	add    $0x1c,%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5f                   	pop    %edi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    
  80210c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802110:	8b 34 24             	mov    (%esp),%esi
  802113:	bf 20 00 00 00       	mov    $0x20,%edi
  802118:	89 e9                	mov    %ebp,%ecx
  80211a:	29 ef                	sub    %ebp,%edi
  80211c:	d3 e0                	shl    %cl,%eax
  80211e:	89 f9                	mov    %edi,%ecx
  802120:	89 f2                	mov    %esi,%edx
  802122:	d3 ea                	shr    %cl,%edx
  802124:	89 e9                	mov    %ebp,%ecx
  802126:	09 c2                	or     %eax,%edx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 14 24             	mov    %edx,(%esp)
  80212d:	89 f2                	mov    %esi,%edx
  80212f:	d3 e2                	shl    %cl,%edx
  802131:	89 f9                	mov    %edi,%ecx
  802133:	89 54 24 04          	mov    %edx,0x4(%esp)
  802137:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	89 e9                	mov    %ebp,%ecx
  80213f:	89 c6                	mov    %eax,%esi
  802141:	d3 e3                	shl    %cl,%ebx
  802143:	89 f9                	mov    %edi,%ecx
  802145:	89 d0                	mov    %edx,%eax
  802147:	d3 e8                	shr    %cl,%eax
  802149:	89 e9                	mov    %ebp,%ecx
  80214b:	09 d8                	or     %ebx,%eax
  80214d:	89 d3                	mov    %edx,%ebx
  80214f:	89 f2                	mov    %esi,%edx
  802151:	f7 34 24             	divl   (%esp)
  802154:	89 d6                	mov    %edx,%esi
  802156:	d3 e3                	shl    %cl,%ebx
  802158:	f7 64 24 04          	mull   0x4(%esp)
  80215c:	39 d6                	cmp    %edx,%esi
  80215e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802162:	89 d1                	mov    %edx,%ecx
  802164:	89 c3                	mov    %eax,%ebx
  802166:	72 08                	jb     802170 <__umoddi3+0x110>
  802168:	75 11                	jne    80217b <__umoddi3+0x11b>
  80216a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80216e:	73 0b                	jae    80217b <__umoddi3+0x11b>
  802170:	2b 44 24 04          	sub    0x4(%esp),%eax
  802174:	1b 14 24             	sbb    (%esp),%edx
  802177:	89 d1                	mov    %edx,%ecx
  802179:	89 c3                	mov    %eax,%ebx
  80217b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80217f:	29 da                	sub    %ebx,%edx
  802181:	19 ce                	sbb    %ecx,%esi
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 f0                	mov    %esi,%eax
  802187:	d3 e0                	shl    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	d3 ea                	shr    %cl,%edx
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	d3 ee                	shr    %cl,%esi
  802191:	09 d0                	or     %edx,%eax
  802193:	89 f2                	mov    %esi,%edx
  802195:	83 c4 1c             	add    $0x1c,%esp
  802198:	5b                   	pop    %ebx
  802199:	5e                   	pop    %esi
  80219a:	5f                   	pop    %edi
  80219b:	5d                   	pop    %ebp
  80219c:	c3                   	ret    
  80219d:	8d 76 00             	lea    0x0(%esi),%esi
  8021a0:	29 f9                	sub    %edi,%ecx
  8021a2:	19 d6                	sbb    %edx,%esi
  8021a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ac:	e9 18 ff ff ff       	jmp    8020c9 <__umoddi3+0x69>
