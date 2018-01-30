
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
  8000b9:	e8 66 0a 00 00       	call   800b24 <close_all>
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
  800132:	68 8a 24 80 00       	push   $0x80248a
  800137:	6a 23                	push   $0x23
  800139:	68 a7 24 80 00       	push   $0x8024a7
  80013e:	e8 12 15 00 00       	call   801655 <_panic>

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
  8001b3:	68 8a 24 80 00       	push   $0x80248a
  8001b8:	6a 23                	push   $0x23
  8001ba:	68 a7 24 80 00       	push   $0x8024a7
  8001bf:	e8 91 14 00 00       	call   801655 <_panic>

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
  8001f5:	68 8a 24 80 00       	push   $0x80248a
  8001fa:	6a 23                	push   $0x23
  8001fc:	68 a7 24 80 00       	push   $0x8024a7
  800201:	e8 4f 14 00 00       	call   801655 <_panic>

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
  800237:	68 8a 24 80 00       	push   $0x80248a
  80023c:	6a 23                	push   $0x23
  80023e:	68 a7 24 80 00       	push   $0x8024a7
  800243:	e8 0d 14 00 00       	call   801655 <_panic>

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
  800279:	68 8a 24 80 00       	push   $0x80248a
  80027e:	6a 23                	push   $0x23
  800280:	68 a7 24 80 00       	push   $0x8024a7
  800285:	e8 cb 13 00 00       	call   801655 <_panic>

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
  8002bb:	68 8a 24 80 00       	push   $0x80248a
  8002c0:	6a 23                	push   $0x23
  8002c2:	68 a7 24 80 00       	push   $0x8024a7
  8002c7:	e8 89 13 00 00       	call   801655 <_panic>
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
  8002fd:	68 8a 24 80 00       	push   $0x80248a
  800302:	6a 23                	push   $0x23
  800304:	68 a7 24 80 00       	push   $0x8024a7
  800309:	e8 47 13 00 00       	call   801655 <_panic>

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
  800361:	68 8a 24 80 00       	push   $0x80248a
  800366:	6a 23                	push   $0x23
  800368:	68 a7 24 80 00       	push   $0x8024a7
  80036d:	e8 e3 12 00 00       	call   801655 <_panic>

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
  800400:	68 b5 24 80 00       	push   $0x8024b5
  800405:	6a 1f                	push   $0x1f
  800407:	68 c5 24 80 00       	push   $0x8024c5
  80040c:	e8 44 12 00 00       	call   801655 <_panic>
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
  80042a:	68 d0 24 80 00       	push   $0x8024d0
  80042f:	6a 2d                	push   $0x2d
  800431:	68 c5 24 80 00       	push   $0x8024c5
  800436:	e8 1a 12 00 00       	call   801655 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80043b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800441:	83 ec 04             	sub    $0x4,%esp
  800444:	68 00 10 00 00       	push   $0x1000
  800449:	53                   	push   %ebx
  80044a:	68 00 f0 7f 00       	push   $0x7ff000
  80044f:	e8 59 1a 00 00       	call   801ead <memcpy>

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
  800472:	68 d0 24 80 00       	push   $0x8024d0
  800477:	6a 34                	push   $0x34
  800479:	68 c5 24 80 00       	push   $0x8024c5
  80047e:	e8 d2 11 00 00       	call   801655 <_panic>
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
  80049a:	68 d0 24 80 00       	push   $0x8024d0
  80049f:	6a 38                	push   $0x38
  8004a1:	68 c5 24 80 00       	push   $0x8024c5
  8004a6:	e8 aa 11 00 00       	call   801655 <_panic>
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
  8004be:	e8 37 1b 00 00       	call   801ffa <set_pgfault_handler>
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
  8004d7:	68 e9 24 80 00       	push   $0x8024e9
  8004dc:	68 85 00 00 00       	push   $0x85
  8004e1:	68 c5 24 80 00       	push   $0x8024c5
  8004e6:	e8 6a 11 00 00       	call   801655 <_panic>
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
  800593:	68 f7 24 80 00       	push   $0x8024f7
  800598:	6a 55                	push   $0x55
  80059a:	68 c5 24 80 00       	push   $0x8024c5
  80059f:	e8 b1 10 00 00       	call   801655 <_panic>
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
  8005d8:	68 f7 24 80 00       	push   $0x8024f7
  8005dd:	6a 5c                	push   $0x5c
  8005df:	68 c5 24 80 00       	push   $0x8024c5
  8005e4:	e8 6c 10 00 00       	call   801655 <_panic>
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
  800606:	68 f7 24 80 00       	push   $0x8024f7
  80060b:	6a 60                	push   $0x60
  80060d:	68 c5 24 80 00       	push   $0x8024c5
  800612:	e8 3e 10 00 00       	call   801655 <_panic>
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
  800630:	68 f7 24 80 00       	push   $0x8024f7
  800635:	6a 65                	push   $0x65
  800637:	68 c5 24 80 00       	push   $0x8024c5
  80063c:	e8 14 10 00 00       	call   801655 <_panic>
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
  80069f:	68 88 25 80 00       	push   $0x802588
  8006a4:	e8 85 10 00 00       	call   80172e <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006a9:	c7 04 24 93 00 80 00 	movl   $0x800093,(%esp)
  8006b0:	e8 c5 fc ff ff       	call   80037a <sys_thread_create>
  8006b5:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006b7:	83 c4 08             	add    $0x8,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	68 88 25 80 00       	push   $0x802588
  8006c0:	e8 69 10 00 00       	call   80172e <cprintf>
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

008006f4 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	56                   	push   %esi
  8006f8:	53                   	push   %ebx
  8006f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8006ff:	83 ec 04             	sub    $0x4,%esp
  800702:	6a 07                	push   $0x7
  800704:	6a 00                	push   $0x0
  800706:	56                   	push   %esi
  800707:	e8 7d fa ff ff       	call   800189 <sys_page_alloc>
	if (r < 0) {
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	85 c0                	test   %eax,%eax
  800711:	79 15                	jns    800728 <queue_append+0x34>
		panic("%e\n", r);
  800713:	50                   	push   %eax
  800714:	68 83 25 80 00       	push   $0x802583
  800719:	68 c4 00 00 00       	push   $0xc4
  80071e:	68 c5 24 80 00       	push   $0x8024c5
  800723:	e8 2d 0f 00 00       	call   801655 <_panic>
	}	
	wt->envid = envid;
  800728:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  80072e:	83 ec 04             	sub    $0x4,%esp
  800731:	ff 33                	pushl  (%ebx)
  800733:	56                   	push   %esi
  800734:	68 ac 25 80 00       	push   $0x8025ac
  800739:	e8 f0 0f 00 00       	call   80172e <cprintf>
	if (queue->first == NULL) {
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	83 3b 00             	cmpl   $0x0,(%ebx)
  800744:	75 29                	jne    80076f <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  800746:	83 ec 0c             	sub    $0xc,%esp
  800749:	68 0d 25 80 00       	push   $0x80250d
  80074e:	e8 db 0f 00 00       	call   80172e <cprintf>
		queue->first = wt;
  800753:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  800759:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  800760:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800767:	00 00 00 
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	eb 2b                	jmp    80079a <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  80076f:	83 ec 0c             	sub    $0xc,%esp
  800772:	68 27 25 80 00       	push   $0x802527
  800777:	e8 b2 0f 00 00       	call   80172e <cprintf>
		queue->last->next = wt;
  80077c:	8b 43 04             	mov    0x4(%ebx),%eax
  80077f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  800786:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80078d:	00 00 00 
		queue->last = wt;
  800790:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  800797:	83 c4 10             	add    $0x10,%esp
	}
}
  80079a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80079d:	5b                   	pop    %ebx
  80079e:	5e                   	pop    %esi
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	53                   	push   %ebx
  8007a5:	83 ec 04             	sub    $0x4,%esp
  8007a8:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8007ab:	8b 02                	mov    (%edx),%eax
  8007ad:	85 c0                	test   %eax,%eax
  8007af:	75 17                	jne    8007c8 <queue_pop+0x27>
		panic("queue empty!\n");
  8007b1:	83 ec 04             	sub    $0x4,%esp
  8007b4:	68 45 25 80 00       	push   $0x802545
  8007b9:	68 d8 00 00 00       	push   $0xd8
  8007be:	68 c5 24 80 00       	push   $0x8024c5
  8007c3:	e8 8d 0e 00 00       	call   801655 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8007c8:	8b 48 04             	mov    0x4(%eax),%ecx
  8007cb:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8007cd:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	53                   	push   %ebx
  8007d3:	68 53 25 80 00       	push   $0x802553
  8007d8:	e8 51 0f 00 00       	call   80172e <cprintf>
	return envid;
}
  8007dd:	89 d8                	mov    %ebx,%eax
  8007df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	53                   	push   %ebx
  8007e8:	83 ec 04             	sub    $0x4,%esp
  8007eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8007ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8007f3:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	74 5a                	je     800854 <mutex_lock+0x70>
  8007fa:	8b 43 04             	mov    0x4(%ebx),%eax
  8007fd:	83 38 00             	cmpl   $0x0,(%eax)
  800800:	75 52                	jne    800854 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  800802:	83 ec 0c             	sub    $0xc,%esp
  800805:	68 d4 25 80 00       	push   $0x8025d4
  80080a:	e8 1f 0f 00 00       	call   80172e <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  80080f:	8b 5b 04             	mov    0x4(%ebx),%ebx
  800812:	e8 34 f9 ff ff       	call   80014b <sys_getenvid>
  800817:	83 c4 08             	add    $0x8,%esp
  80081a:	53                   	push   %ebx
  80081b:	50                   	push   %eax
  80081c:	e8 d3 fe ff ff       	call   8006f4 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800821:	e8 25 f9 ff ff       	call   80014b <sys_getenvid>
  800826:	83 c4 08             	add    $0x8,%esp
  800829:	6a 04                	push   $0x4
  80082b:	50                   	push   %eax
  80082c:	e8 1f fa ff ff       	call   800250 <sys_env_set_status>
		if (r < 0) {
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	85 c0                	test   %eax,%eax
  800836:	79 15                	jns    80084d <mutex_lock+0x69>
			panic("%e\n", r);
  800838:	50                   	push   %eax
  800839:	68 83 25 80 00       	push   $0x802583
  80083e:	68 eb 00 00 00       	push   $0xeb
  800843:	68 c5 24 80 00       	push   $0x8024c5
  800848:	e8 08 0e 00 00       	call   801655 <_panic>
		}
		sys_yield();
  80084d:	e8 18 f9 ff ff       	call   80016a <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800852:	eb 18                	jmp    80086c <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  800854:	83 ec 0c             	sub    $0xc,%esp
  800857:	68 f4 25 80 00       	push   $0x8025f4
  80085c:	e8 cd 0e 00 00       	call   80172e <cprintf>
	mtx->owner = sys_getenvid();}
  800861:	e8 e5 f8 ff ff       	call   80014b <sys_getenvid>
  800866:	89 43 08             	mov    %eax,0x8(%ebx)
  800869:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  80086c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	53                   	push   %ebx
  800875:	83 ec 04             	sub    $0x4,%esp
  800878:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
  800880:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  800883:	8b 43 04             	mov    0x4(%ebx),%eax
  800886:	83 38 00             	cmpl   $0x0,(%eax)
  800889:	74 33                	je     8008be <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80088b:	83 ec 0c             	sub    $0xc,%esp
  80088e:	50                   	push   %eax
  80088f:	e8 0d ff ff ff       	call   8007a1 <queue_pop>
  800894:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  800897:	83 c4 08             	add    $0x8,%esp
  80089a:	6a 02                	push   $0x2
  80089c:	50                   	push   %eax
  80089d:	e8 ae f9 ff ff       	call   800250 <sys_env_set_status>
		if (r < 0) {
  8008a2:	83 c4 10             	add    $0x10,%esp
  8008a5:	85 c0                	test   %eax,%eax
  8008a7:	79 15                	jns    8008be <mutex_unlock+0x4d>
			panic("%e\n", r);
  8008a9:	50                   	push   %eax
  8008aa:	68 83 25 80 00       	push   $0x802583
  8008af:	68 00 01 00 00       	push   $0x100
  8008b4:	68 c5 24 80 00       	push   $0x8024c5
  8008b9:	e8 97 0d 00 00       	call   801655 <_panic>
		}
	}

	asm volatile("pause");
  8008be:	f3 90                	pause  
	//sys_yield();
}
  8008c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c3:	c9                   	leave  
  8008c4:	c3                   	ret    

008008c5 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	53                   	push   %ebx
  8008c9:	83 ec 04             	sub    $0x4,%esp
  8008cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8008cf:	e8 77 f8 ff ff       	call   80014b <sys_getenvid>
  8008d4:	83 ec 04             	sub    $0x4,%esp
  8008d7:	6a 07                	push   $0x7
  8008d9:	53                   	push   %ebx
  8008da:	50                   	push   %eax
  8008db:	e8 a9 f8 ff ff       	call   800189 <sys_page_alloc>
  8008e0:	83 c4 10             	add    $0x10,%esp
  8008e3:	85 c0                	test   %eax,%eax
  8008e5:	79 15                	jns    8008fc <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8008e7:	50                   	push   %eax
  8008e8:	68 6e 25 80 00       	push   $0x80256e
  8008ed:	68 0d 01 00 00       	push   $0x10d
  8008f2:	68 c5 24 80 00       	push   $0x8024c5
  8008f7:	e8 59 0d 00 00       	call   801655 <_panic>
	}	
	mtx->locked = 0;
  8008fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  800902:	8b 43 04             	mov    0x4(%ebx),%eax
  800905:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80090b:	8b 43 04             	mov    0x4(%ebx),%eax
  80090e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  800915:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80091c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091f:	c9                   	leave  
  800920:	c3                   	ret    

00800921 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  800927:	e8 1f f8 ff ff       	call   80014b <sys_getenvid>
  80092c:	83 ec 08             	sub    $0x8,%esp
  80092f:	ff 75 08             	pushl  0x8(%ebp)
  800932:	50                   	push   %eax
  800933:	e8 d6 f8 ff ff       	call   80020e <sys_page_unmap>
	if (r < 0) {
  800938:	83 c4 10             	add    $0x10,%esp
  80093b:	85 c0                	test   %eax,%eax
  80093d:	79 15                	jns    800954 <mutex_destroy+0x33>
		panic("%e\n", r);
  80093f:	50                   	push   %eax
  800940:	68 83 25 80 00       	push   $0x802583
  800945:	68 1a 01 00 00       	push   $0x11a
  80094a:	68 c5 24 80 00       	push   $0x8024c5
  80094f:	e8 01 0d 00 00       	call   801655 <_panic>
	}
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    

00800956 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	05 00 00 00 30       	add    $0x30000000,%eax
  800961:	c1 e8 0c             	shr    $0xc,%eax
}
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	05 00 00 00 30       	add    $0x30000000,%eax
  800971:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800976:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800983:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800988:	89 c2                	mov    %eax,%edx
  80098a:	c1 ea 16             	shr    $0x16,%edx
  80098d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800994:	f6 c2 01             	test   $0x1,%dl
  800997:	74 11                	je     8009aa <fd_alloc+0x2d>
  800999:	89 c2                	mov    %eax,%edx
  80099b:	c1 ea 0c             	shr    $0xc,%edx
  80099e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8009a5:	f6 c2 01             	test   $0x1,%dl
  8009a8:	75 09                	jne    8009b3 <fd_alloc+0x36>
			*fd_store = fd;
  8009aa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b1:	eb 17                	jmp    8009ca <fd_alloc+0x4d>
  8009b3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8009b8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8009bd:	75 c9                	jne    800988 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8009bf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8009c5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8009d2:	83 f8 1f             	cmp    $0x1f,%eax
  8009d5:	77 36                	ja     800a0d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8009d7:	c1 e0 0c             	shl    $0xc,%eax
  8009da:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8009df:	89 c2                	mov    %eax,%edx
  8009e1:	c1 ea 16             	shr    $0x16,%edx
  8009e4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8009eb:	f6 c2 01             	test   $0x1,%dl
  8009ee:	74 24                	je     800a14 <fd_lookup+0x48>
  8009f0:	89 c2                	mov    %eax,%edx
  8009f2:	c1 ea 0c             	shr    $0xc,%edx
  8009f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8009fc:	f6 c2 01             	test   $0x1,%dl
  8009ff:	74 1a                	je     800a1b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800a01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a04:	89 02                	mov    %eax,(%edx)
	return 0;
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	eb 13                	jmp    800a20 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a12:	eb 0c                	jmp    800a20 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a19:	eb 05                	jmp    800a20 <fd_lookup+0x54>
  800a1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	83 ec 08             	sub    $0x8,%esp
  800a28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2b:	ba 90 26 80 00       	mov    $0x802690,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800a30:	eb 13                	jmp    800a45 <dev_lookup+0x23>
  800a32:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800a35:	39 08                	cmp    %ecx,(%eax)
  800a37:	75 0c                	jne    800a45 <dev_lookup+0x23>
			*dev = devtab[i];
  800a39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a43:	eb 31                	jmp    800a76 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800a45:	8b 02                	mov    (%edx),%eax
  800a47:	85 c0                	test   %eax,%eax
  800a49:	75 e7                	jne    800a32 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800a4b:	a1 04 40 80 00       	mov    0x804004,%eax
  800a50:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a56:	83 ec 04             	sub    $0x4,%esp
  800a59:	51                   	push   %ecx
  800a5a:	50                   	push   %eax
  800a5b:	68 14 26 80 00       	push   $0x802614
  800a60:	e8 c9 0c 00 00       	call   80172e <cprintf>
	*dev = 0;
  800a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a68:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800a6e:	83 c4 10             	add    $0x10,%esp
  800a71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	83 ec 10             	sub    $0x10,%esp
  800a80:	8b 75 08             	mov    0x8(%ebp),%esi
  800a83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a89:	50                   	push   %eax
  800a8a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a90:	c1 e8 0c             	shr    $0xc,%eax
  800a93:	50                   	push   %eax
  800a94:	e8 33 ff ff ff       	call   8009cc <fd_lookup>
  800a99:	83 c4 08             	add    $0x8,%esp
  800a9c:	85 c0                	test   %eax,%eax
  800a9e:	78 05                	js     800aa5 <fd_close+0x2d>
	    || fd != fd2)
  800aa0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800aa3:	74 0c                	je     800ab1 <fd_close+0x39>
		return (must_exist ? r : 0);
  800aa5:	84 db                	test   %bl,%bl
  800aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aac:	0f 44 c2             	cmove  %edx,%eax
  800aaf:	eb 41                	jmp    800af2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ab1:	83 ec 08             	sub    $0x8,%esp
  800ab4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ab7:	50                   	push   %eax
  800ab8:	ff 36                	pushl  (%esi)
  800aba:	e8 63 ff ff ff       	call   800a22 <dev_lookup>
  800abf:	89 c3                	mov    %eax,%ebx
  800ac1:	83 c4 10             	add    $0x10,%esp
  800ac4:	85 c0                	test   %eax,%eax
  800ac6:	78 1a                	js     800ae2 <fd_close+0x6a>
		if (dev->dev_close)
  800ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800acb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ace:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	74 0b                	je     800ae2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ad7:	83 ec 0c             	sub    $0xc,%esp
  800ada:	56                   	push   %esi
  800adb:	ff d0                	call   *%eax
  800add:	89 c3                	mov    %eax,%ebx
  800adf:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ae2:	83 ec 08             	sub    $0x8,%esp
  800ae5:	56                   	push   %esi
  800ae6:	6a 00                	push   $0x0
  800ae8:	e8 21 f7 ff ff       	call   80020e <sys_page_unmap>
	return r;
  800aed:	83 c4 10             	add    $0x10,%esp
  800af0:	89 d8                	mov    %ebx,%eax
}
  800af2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800aff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b02:	50                   	push   %eax
  800b03:	ff 75 08             	pushl  0x8(%ebp)
  800b06:	e8 c1 fe ff ff       	call   8009cc <fd_lookup>
  800b0b:	83 c4 08             	add    $0x8,%esp
  800b0e:	85 c0                	test   %eax,%eax
  800b10:	78 10                	js     800b22 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800b12:	83 ec 08             	sub    $0x8,%esp
  800b15:	6a 01                	push   $0x1
  800b17:	ff 75 f4             	pushl  -0xc(%ebp)
  800b1a:	e8 59 ff ff ff       	call   800a78 <fd_close>
  800b1f:	83 c4 10             	add    $0x10,%esp
}
  800b22:	c9                   	leave  
  800b23:	c3                   	ret    

00800b24 <close_all>:

void
close_all(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	53                   	push   %ebx
  800b28:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800b2b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800b30:	83 ec 0c             	sub    $0xc,%esp
  800b33:	53                   	push   %ebx
  800b34:	e8 c0 ff ff ff       	call   800af9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800b39:	83 c3 01             	add    $0x1,%ebx
  800b3c:	83 c4 10             	add    $0x10,%esp
  800b3f:	83 fb 20             	cmp    $0x20,%ebx
  800b42:	75 ec                	jne    800b30 <close_all+0xc>
		close(i);
}
  800b44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    

00800b49 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	83 ec 2c             	sub    $0x2c,%esp
  800b52:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800b55:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800b58:	50                   	push   %eax
  800b59:	ff 75 08             	pushl  0x8(%ebp)
  800b5c:	e8 6b fe ff ff       	call   8009cc <fd_lookup>
  800b61:	83 c4 08             	add    $0x8,%esp
  800b64:	85 c0                	test   %eax,%eax
  800b66:	0f 88 c1 00 00 00    	js     800c2d <dup+0xe4>
		return r;
	close(newfdnum);
  800b6c:	83 ec 0c             	sub    $0xc,%esp
  800b6f:	56                   	push   %esi
  800b70:	e8 84 ff ff ff       	call   800af9 <close>

	newfd = INDEX2FD(newfdnum);
  800b75:	89 f3                	mov    %esi,%ebx
  800b77:	c1 e3 0c             	shl    $0xc,%ebx
  800b7a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b80:	83 c4 04             	add    $0x4,%esp
  800b83:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b86:	e8 db fd ff ff       	call   800966 <fd2data>
  800b8b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b8d:	89 1c 24             	mov    %ebx,(%esp)
  800b90:	e8 d1 fd ff ff       	call   800966 <fd2data>
  800b95:	83 c4 10             	add    $0x10,%esp
  800b98:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b9b:	89 f8                	mov    %edi,%eax
  800b9d:	c1 e8 16             	shr    $0x16,%eax
  800ba0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ba7:	a8 01                	test   $0x1,%al
  800ba9:	74 37                	je     800be2 <dup+0x99>
  800bab:	89 f8                	mov    %edi,%eax
  800bad:	c1 e8 0c             	shr    $0xc,%eax
  800bb0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800bb7:	f6 c2 01             	test   $0x1,%dl
  800bba:	74 26                	je     800be2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800bbc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	25 07 0e 00 00       	and    $0xe07,%eax
  800bcb:	50                   	push   %eax
  800bcc:	ff 75 d4             	pushl  -0x2c(%ebp)
  800bcf:	6a 00                	push   $0x0
  800bd1:	57                   	push   %edi
  800bd2:	6a 00                	push   $0x0
  800bd4:	e8 f3 f5 ff ff       	call   8001cc <sys_page_map>
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	83 c4 20             	add    $0x20,%esp
  800bde:	85 c0                	test   %eax,%eax
  800be0:	78 2e                	js     800c10 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800be2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800be5:	89 d0                	mov    %edx,%eax
  800be7:	c1 e8 0c             	shr    $0xc,%eax
  800bea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	25 07 0e 00 00       	and    $0xe07,%eax
  800bf9:	50                   	push   %eax
  800bfa:	53                   	push   %ebx
  800bfb:	6a 00                	push   $0x0
  800bfd:	52                   	push   %edx
  800bfe:	6a 00                	push   $0x0
  800c00:	e8 c7 f5 ff ff       	call   8001cc <sys_page_map>
  800c05:	89 c7                	mov    %eax,%edi
  800c07:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800c0a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800c0c:	85 ff                	test   %edi,%edi
  800c0e:	79 1d                	jns    800c2d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800c10:	83 ec 08             	sub    $0x8,%esp
  800c13:	53                   	push   %ebx
  800c14:	6a 00                	push   $0x0
  800c16:	e8 f3 f5 ff ff       	call   80020e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800c1b:	83 c4 08             	add    $0x8,%esp
  800c1e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800c21:	6a 00                	push   $0x0
  800c23:	e8 e6 f5 ff ff       	call   80020e <sys_page_unmap>
	return r;
  800c28:	83 c4 10             	add    $0x10,%esp
  800c2b:	89 f8                	mov    %edi,%eax
}
  800c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	53                   	push   %ebx
  800c39:	83 ec 14             	sub    $0x14,%esp
  800c3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c3f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c42:	50                   	push   %eax
  800c43:	53                   	push   %ebx
  800c44:	e8 83 fd ff ff       	call   8009cc <fd_lookup>
  800c49:	83 c4 08             	add    $0x8,%esp
  800c4c:	89 c2                	mov    %eax,%edx
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	78 70                	js     800cc2 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c52:	83 ec 08             	sub    $0x8,%esp
  800c55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c58:	50                   	push   %eax
  800c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c5c:	ff 30                	pushl  (%eax)
  800c5e:	e8 bf fd ff ff       	call   800a22 <dev_lookup>
  800c63:	83 c4 10             	add    $0x10,%esp
  800c66:	85 c0                	test   %eax,%eax
  800c68:	78 4f                	js     800cb9 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800c6a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c6d:	8b 42 08             	mov    0x8(%edx),%eax
  800c70:	83 e0 03             	and    $0x3,%eax
  800c73:	83 f8 01             	cmp    $0x1,%eax
  800c76:	75 24                	jne    800c9c <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800c78:	a1 04 40 80 00       	mov    0x804004,%eax
  800c7d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800c83:	83 ec 04             	sub    $0x4,%esp
  800c86:	53                   	push   %ebx
  800c87:	50                   	push   %eax
  800c88:	68 55 26 80 00       	push   $0x802655
  800c8d:	e8 9c 0a 00 00       	call   80172e <cprintf>
		return -E_INVAL;
  800c92:	83 c4 10             	add    $0x10,%esp
  800c95:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c9a:	eb 26                	jmp    800cc2 <read+0x8d>
	}
	if (!dev->dev_read)
  800c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9f:	8b 40 08             	mov    0x8(%eax),%eax
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	74 17                	je     800cbd <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800ca6:	83 ec 04             	sub    $0x4,%esp
  800ca9:	ff 75 10             	pushl  0x10(%ebp)
  800cac:	ff 75 0c             	pushl  0xc(%ebp)
  800caf:	52                   	push   %edx
  800cb0:	ff d0                	call   *%eax
  800cb2:	89 c2                	mov    %eax,%edx
  800cb4:	83 c4 10             	add    $0x10,%esp
  800cb7:	eb 09                	jmp    800cc2 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cb9:	89 c2                	mov    %eax,%edx
  800cbb:	eb 05                	jmp    800cc2 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800cbd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800cc2:	89 d0                	mov    %edx,%eax
  800cc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cc7:	c9                   	leave  
  800cc8:	c3                   	ret    

00800cc9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cd5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdd:	eb 21                	jmp    800d00 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800cdf:	83 ec 04             	sub    $0x4,%esp
  800ce2:	89 f0                	mov    %esi,%eax
  800ce4:	29 d8                	sub    %ebx,%eax
  800ce6:	50                   	push   %eax
  800ce7:	89 d8                	mov    %ebx,%eax
  800ce9:	03 45 0c             	add    0xc(%ebp),%eax
  800cec:	50                   	push   %eax
  800ced:	57                   	push   %edi
  800cee:	e8 42 ff ff ff       	call   800c35 <read>
		if (m < 0)
  800cf3:	83 c4 10             	add    $0x10,%esp
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	78 10                	js     800d0a <readn+0x41>
			return m;
		if (m == 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	74 0a                	je     800d08 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800cfe:	01 c3                	add    %eax,%ebx
  800d00:	39 f3                	cmp    %esi,%ebx
  800d02:	72 db                	jb     800cdf <readn+0x16>
  800d04:	89 d8                	mov    %ebx,%eax
  800d06:	eb 02                	jmp    800d0a <readn+0x41>
  800d08:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	53                   	push   %ebx
  800d16:	83 ec 14             	sub    $0x14,%esp
  800d19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d1c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d1f:	50                   	push   %eax
  800d20:	53                   	push   %ebx
  800d21:	e8 a6 fc ff ff       	call   8009cc <fd_lookup>
  800d26:	83 c4 08             	add    $0x8,%esp
  800d29:	89 c2                	mov    %eax,%edx
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	78 6b                	js     800d9a <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d2f:	83 ec 08             	sub    $0x8,%esp
  800d32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d35:	50                   	push   %eax
  800d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d39:	ff 30                	pushl  (%eax)
  800d3b:	e8 e2 fc ff ff       	call   800a22 <dev_lookup>
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	85 c0                	test   %eax,%eax
  800d45:	78 4a                	js     800d91 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d4a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d4e:	75 24                	jne    800d74 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800d50:	a1 04 40 80 00       	mov    0x804004,%eax
  800d55:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800d5b:	83 ec 04             	sub    $0x4,%esp
  800d5e:	53                   	push   %ebx
  800d5f:	50                   	push   %eax
  800d60:	68 71 26 80 00       	push   $0x802671
  800d65:	e8 c4 09 00 00       	call   80172e <cprintf>
		return -E_INVAL;
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d72:	eb 26                	jmp    800d9a <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800d74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d77:	8b 52 0c             	mov    0xc(%edx),%edx
  800d7a:	85 d2                	test   %edx,%edx
  800d7c:	74 17                	je     800d95 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d7e:	83 ec 04             	sub    $0x4,%esp
  800d81:	ff 75 10             	pushl  0x10(%ebp)
  800d84:	ff 75 0c             	pushl  0xc(%ebp)
  800d87:	50                   	push   %eax
  800d88:	ff d2                	call   *%edx
  800d8a:	89 c2                	mov    %eax,%edx
  800d8c:	83 c4 10             	add    $0x10,%esp
  800d8f:	eb 09                	jmp    800d9a <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	eb 05                	jmp    800d9a <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d95:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d9a:	89 d0                	mov    %edx,%eax
  800d9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d9f:	c9                   	leave  
  800da0:	c3                   	ret    

00800da1 <seek>:

int
seek(int fdnum, off_t offset)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800da7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800daa:	50                   	push   %eax
  800dab:	ff 75 08             	pushl  0x8(%ebp)
  800dae:	e8 19 fc ff ff       	call   8009cc <fd_lookup>
  800db3:	83 c4 08             	add    $0x8,%esp
  800db6:	85 c0                	test   %eax,%eax
  800db8:	78 0e                	js     800dc8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800dba:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800dbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800dc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc8:	c9                   	leave  
  800dc9:	c3                   	ret    

00800dca <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 14             	sub    $0x14,%esp
  800dd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dd4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dd7:	50                   	push   %eax
  800dd8:	53                   	push   %ebx
  800dd9:	e8 ee fb ff ff       	call   8009cc <fd_lookup>
  800dde:	83 c4 08             	add    $0x8,%esp
  800de1:	89 c2                	mov    %eax,%edx
  800de3:	85 c0                	test   %eax,%eax
  800de5:	78 68                	js     800e4f <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800de7:	83 ec 08             	sub    $0x8,%esp
  800dea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ded:	50                   	push   %eax
  800dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df1:	ff 30                	pushl  (%eax)
  800df3:	e8 2a fc ff ff       	call   800a22 <dev_lookup>
  800df8:	83 c4 10             	add    $0x10,%esp
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	78 47                	js     800e46 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e02:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800e06:	75 24                	jne    800e2c <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800e08:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800e0d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800e13:	83 ec 04             	sub    $0x4,%esp
  800e16:	53                   	push   %ebx
  800e17:	50                   	push   %eax
  800e18:	68 34 26 80 00       	push   $0x802634
  800e1d:	e8 0c 09 00 00       	call   80172e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800e22:	83 c4 10             	add    $0x10,%esp
  800e25:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800e2a:	eb 23                	jmp    800e4f <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800e2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e2f:	8b 52 18             	mov    0x18(%edx),%edx
  800e32:	85 d2                	test   %edx,%edx
  800e34:	74 14                	je     800e4a <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800e36:	83 ec 08             	sub    $0x8,%esp
  800e39:	ff 75 0c             	pushl  0xc(%ebp)
  800e3c:	50                   	push   %eax
  800e3d:	ff d2                	call   *%edx
  800e3f:	89 c2                	mov    %eax,%edx
  800e41:	83 c4 10             	add    $0x10,%esp
  800e44:	eb 09                	jmp    800e4f <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e46:	89 c2                	mov    %eax,%edx
  800e48:	eb 05                	jmp    800e4f <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800e4a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800e4f:	89 d0                	mov    %edx,%eax
  800e51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e54:	c9                   	leave  
  800e55:	c3                   	ret    

00800e56 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 14             	sub    $0x14,%esp
  800e5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e60:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e63:	50                   	push   %eax
  800e64:	ff 75 08             	pushl  0x8(%ebp)
  800e67:	e8 60 fb ff ff       	call   8009cc <fd_lookup>
  800e6c:	83 c4 08             	add    $0x8,%esp
  800e6f:	89 c2                	mov    %eax,%edx
  800e71:	85 c0                	test   %eax,%eax
  800e73:	78 58                	js     800ecd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e75:	83 ec 08             	sub    $0x8,%esp
  800e78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e7b:	50                   	push   %eax
  800e7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e7f:	ff 30                	pushl  (%eax)
  800e81:	e8 9c fb ff ff       	call   800a22 <dev_lookup>
  800e86:	83 c4 10             	add    $0x10,%esp
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	78 37                	js     800ec4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e90:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e94:	74 32                	je     800ec8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e96:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e99:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800ea0:	00 00 00 
	stat->st_isdir = 0;
  800ea3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800eaa:	00 00 00 
	stat->st_dev = dev;
  800ead:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800eb3:	83 ec 08             	sub    $0x8,%esp
  800eb6:	53                   	push   %ebx
  800eb7:	ff 75 f0             	pushl  -0x10(%ebp)
  800eba:	ff 50 14             	call   *0x14(%eax)
  800ebd:	89 c2                	mov    %eax,%edx
  800ebf:	83 c4 10             	add    $0x10,%esp
  800ec2:	eb 09                	jmp    800ecd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ec4:	89 c2                	mov    %eax,%edx
  800ec6:	eb 05                	jmp    800ecd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800ec8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800ecd:	89 d0                	mov    %edx,%eax
  800ecf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed2:	c9                   	leave  
  800ed3:	c3                   	ret    

00800ed4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800ed9:	83 ec 08             	sub    $0x8,%esp
  800edc:	6a 00                	push   $0x0
  800ede:	ff 75 08             	pushl  0x8(%ebp)
  800ee1:	e8 e3 01 00 00       	call   8010c9 <open>
  800ee6:	89 c3                	mov    %eax,%ebx
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	78 1b                	js     800f0a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800eef:	83 ec 08             	sub    $0x8,%esp
  800ef2:	ff 75 0c             	pushl  0xc(%ebp)
  800ef5:	50                   	push   %eax
  800ef6:	e8 5b ff ff ff       	call   800e56 <fstat>
  800efb:	89 c6                	mov    %eax,%esi
	close(fd);
  800efd:	89 1c 24             	mov    %ebx,(%esp)
  800f00:	e8 f4 fb ff ff       	call   800af9 <close>
	return r;
  800f05:	83 c4 10             	add    $0x10,%esp
  800f08:	89 f0                	mov    %esi,%eax
}
  800f0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	89 c6                	mov    %eax,%esi
  800f18:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800f1a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800f21:	75 12                	jne    800f35 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800f23:	83 ec 0c             	sub    $0xc,%esp
  800f26:	6a 01                	push   $0x1
  800f28:	e8 39 12 00 00       	call   802166 <ipc_find_env>
  800f2d:	a3 00 40 80 00       	mov    %eax,0x804000
  800f32:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800f35:	6a 07                	push   $0x7
  800f37:	68 00 50 80 00       	push   $0x805000
  800f3c:	56                   	push   %esi
  800f3d:	ff 35 00 40 80 00    	pushl  0x804000
  800f43:	e8 bc 11 00 00       	call   802104 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800f48:	83 c4 0c             	add    $0xc,%esp
  800f4b:	6a 00                	push   $0x0
  800f4d:	53                   	push   %ebx
  800f4e:	6a 00                	push   $0x0
  800f50:	e8 34 11 00 00       	call   802089 <ipc_recv>
}
  800f55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    

00800f5c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800f62:	8b 45 08             	mov    0x8(%ebp),%eax
  800f65:	8b 40 0c             	mov    0xc(%eax),%eax
  800f68:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f70:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800f75:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7a:	b8 02 00 00 00       	mov    $0x2,%eax
  800f7f:	e8 8d ff ff ff       	call   800f11 <fsipc>
}
  800f84:	c9                   	leave  
  800f85:	c3                   	ret    

00800f86 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8f:	8b 40 0c             	mov    0xc(%eax),%eax
  800f92:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f97:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9c:	b8 06 00 00 00       	mov    $0x6,%eax
  800fa1:	e8 6b ff ff ff       	call   800f11 <fsipc>
}
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	53                   	push   %ebx
  800fac:	83 ec 04             	sub    $0x4,%esp
  800faf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb5:	8b 40 0c             	mov    0xc(%eax),%eax
  800fb8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800fbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800fc7:	e8 45 ff ff ff       	call   800f11 <fsipc>
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	78 2c                	js     800ffc <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800fd0:	83 ec 08             	sub    $0x8,%esp
  800fd3:	68 00 50 80 00       	push   $0x805000
  800fd8:	53                   	push   %ebx
  800fd9:	e8 d5 0c 00 00       	call   801cb3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800fde:	a1 80 50 80 00       	mov    0x805080,%eax
  800fe3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800fe9:	a1 84 50 80 00       	mov    0x805084,%eax
  800fee:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ffc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fff:	c9                   	leave  
  801000:	c3                   	ret    

00801001 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80100a:	8b 55 08             	mov    0x8(%ebp),%edx
  80100d:	8b 52 0c             	mov    0xc(%edx),%edx
  801010:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801016:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80101b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801020:	0f 47 c2             	cmova  %edx,%eax
  801023:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801028:	50                   	push   %eax
  801029:	ff 75 0c             	pushl  0xc(%ebp)
  80102c:	68 08 50 80 00       	push   $0x805008
  801031:	e8 0f 0e 00 00       	call   801e45 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801036:	ba 00 00 00 00       	mov    $0x0,%edx
  80103b:	b8 04 00 00 00       	mov    $0x4,%eax
  801040:	e8 cc fe ff ff       	call   800f11 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801045:	c9                   	leave  
  801046:	c3                   	ret    

00801047 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	56                   	push   %esi
  80104b:	53                   	push   %ebx
  80104c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80104f:	8b 45 08             	mov    0x8(%ebp),%eax
  801052:	8b 40 0c             	mov    0xc(%eax),%eax
  801055:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80105a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801060:	ba 00 00 00 00       	mov    $0x0,%edx
  801065:	b8 03 00 00 00       	mov    $0x3,%eax
  80106a:	e8 a2 fe ff ff       	call   800f11 <fsipc>
  80106f:	89 c3                	mov    %eax,%ebx
  801071:	85 c0                	test   %eax,%eax
  801073:	78 4b                	js     8010c0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801075:	39 c6                	cmp    %eax,%esi
  801077:	73 16                	jae    80108f <devfile_read+0x48>
  801079:	68 a0 26 80 00       	push   $0x8026a0
  80107e:	68 a7 26 80 00       	push   $0x8026a7
  801083:	6a 7c                	push   $0x7c
  801085:	68 bc 26 80 00       	push   $0x8026bc
  80108a:	e8 c6 05 00 00       	call   801655 <_panic>
	assert(r <= PGSIZE);
  80108f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801094:	7e 16                	jle    8010ac <devfile_read+0x65>
  801096:	68 c7 26 80 00       	push   $0x8026c7
  80109b:	68 a7 26 80 00       	push   $0x8026a7
  8010a0:	6a 7d                	push   $0x7d
  8010a2:	68 bc 26 80 00       	push   $0x8026bc
  8010a7:	e8 a9 05 00 00       	call   801655 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8010ac:	83 ec 04             	sub    $0x4,%esp
  8010af:	50                   	push   %eax
  8010b0:	68 00 50 80 00       	push   $0x805000
  8010b5:	ff 75 0c             	pushl  0xc(%ebp)
  8010b8:	e8 88 0d 00 00       	call   801e45 <memmove>
	return r;
  8010bd:	83 c4 10             	add    $0x10,%esp
}
  8010c0:	89 d8                	mov    %ebx,%eax
  8010c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5d                   	pop    %ebp
  8010c8:	c3                   	ret    

008010c9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	53                   	push   %ebx
  8010cd:	83 ec 20             	sub    $0x20,%esp
  8010d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8010d3:	53                   	push   %ebx
  8010d4:	e8 a1 0b 00 00       	call   801c7a <strlen>
  8010d9:	83 c4 10             	add    $0x10,%esp
  8010dc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8010e1:	7f 67                	jg     80114a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010e3:	83 ec 0c             	sub    $0xc,%esp
  8010e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e9:	50                   	push   %eax
  8010ea:	e8 8e f8 ff ff       	call   80097d <fd_alloc>
  8010ef:	83 c4 10             	add    $0x10,%esp
		return r;
  8010f2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	78 57                	js     80114f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8010f8:	83 ec 08             	sub    $0x8,%esp
  8010fb:	53                   	push   %ebx
  8010fc:	68 00 50 80 00       	push   $0x805000
  801101:	e8 ad 0b 00 00       	call   801cb3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801106:	8b 45 0c             	mov    0xc(%ebp),%eax
  801109:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80110e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801111:	b8 01 00 00 00       	mov    $0x1,%eax
  801116:	e8 f6 fd ff ff       	call   800f11 <fsipc>
  80111b:	89 c3                	mov    %eax,%ebx
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	85 c0                	test   %eax,%eax
  801122:	79 14                	jns    801138 <open+0x6f>
		fd_close(fd, 0);
  801124:	83 ec 08             	sub    $0x8,%esp
  801127:	6a 00                	push   $0x0
  801129:	ff 75 f4             	pushl  -0xc(%ebp)
  80112c:	e8 47 f9 ff ff       	call   800a78 <fd_close>
		return r;
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	89 da                	mov    %ebx,%edx
  801136:	eb 17                	jmp    80114f <open+0x86>
	}

	return fd2num(fd);
  801138:	83 ec 0c             	sub    $0xc,%esp
  80113b:	ff 75 f4             	pushl  -0xc(%ebp)
  80113e:	e8 13 f8 ff ff       	call   800956 <fd2num>
  801143:	89 c2                	mov    %eax,%edx
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	eb 05                	jmp    80114f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80114a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80114f:	89 d0                	mov    %edx,%eax
  801151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801154:	c9                   	leave  
  801155:	c3                   	ret    

00801156 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80115c:	ba 00 00 00 00       	mov    $0x0,%edx
  801161:	b8 08 00 00 00       	mov    $0x8,%eax
  801166:	e8 a6 fd ff ff       	call   800f11 <fsipc>
}
  80116b:	c9                   	leave  
  80116c:	c3                   	ret    

0080116d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	56                   	push   %esi
  801171:	53                   	push   %ebx
  801172:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801175:	83 ec 0c             	sub    $0xc,%esp
  801178:	ff 75 08             	pushl  0x8(%ebp)
  80117b:	e8 e6 f7 ff ff       	call   800966 <fd2data>
  801180:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801182:	83 c4 08             	add    $0x8,%esp
  801185:	68 d3 26 80 00       	push   $0x8026d3
  80118a:	53                   	push   %ebx
  80118b:	e8 23 0b 00 00       	call   801cb3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801190:	8b 46 04             	mov    0x4(%esi),%eax
  801193:	2b 06                	sub    (%esi),%eax
  801195:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80119b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8011a2:	00 00 00 
	stat->st_dev = &devpipe;
  8011a5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8011ac:	30 80 00 
	return 0;
}
  8011af:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011b7:	5b                   	pop    %ebx
  8011b8:	5e                   	pop    %esi
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 0c             	sub    $0xc,%esp
  8011c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8011c5:	53                   	push   %ebx
  8011c6:	6a 00                	push   $0x0
  8011c8:	e8 41 f0 ff ff       	call   80020e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8011cd:	89 1c 24             	mov    %ebx,(%esp)
  8011d0:	e8 91 f7 ff ff       	call   800966 <fd2data>
  8011d5:	83 c4 08             	add    $0x8,%esp
  8011d8:	50                   	push   %eax
  8011d9:	6a 00                	push   $0x0
  8011db:	e8 2e f0 ff ff       	call   80020e <sys_page_unmap>
}
  8011e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e3:	c9                   	leave  
  8011e4:	c3                   	ret    

008011e5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
  8011eb:	83 ec 1c             	sub    $0x1c,%esp
  8011ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011f1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8011f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f8:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8011fe:	83 ec 0c             	sub    $0xc,%esp
  801201:	ff 75 e0             	pushl  -0x20(%ebp)
  801204:	e8 a2 0f 00 00       	call   8021ab <pageref>
  801209:	89 c3                	mov    %eax,%ebx
  80120b:	89 3c 24             	mov    %edi,(%esp)
  80120e:	e8 98 0f 00 00       	call   8021ab <pageref>
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	39 c3                	cmp    %eax,%ebx
  801218:	0f 94 c1             	sete   %cl
  80121b:	0f b6 c9             	movzbl %cl,%ecx
  80121e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801221:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801227:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  80122d:	39 ce                	cmp    %ecx,%esi
  80122f:	74 1e                	je     80124f <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801231:	39 c3                	cmp    %eax,%ebx
  801233:	75 be                	jne    8011f3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801235:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  80123b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80123e:	50                   	push   %eax
  80123f:	56                   	push   %esi
  801240:	68 da 26 80 00       	push   $0x8026da
  801245:	e8 e4 04 00 00       	call   80172e <cprintf>
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	eb a4                	jmp    8011f3 <_pipeisclosed+0xe>
	}
}
  80124f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801255:	5b                   	pop    %ebx
  801256:	5e                   	pop    %esi
  801257:	5f                   	pop    %edi
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	57                   	push   %edi
  80125e:	56                   	push   %esi
  80125f:	53                   	push   %ebx
  801260:	83 ec 28             	sub    $0x28,%esp
  801263:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801266:	56                   	push   %esi
  801267:	e8 fa f6 ff ff       	call   800966 <fd2data>
  80126c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	bf 00 00 00 00       	mov    $0x0,%edi
  801276:	eb 4b                	jmp    8012c3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801278:	89 da                	mov    %ebx,%edx
  80127a:	89 f0                	mov    %esi,%eax
  80127c:	e8 64 ff ff ff       	call   8011e5 <_pipeisclosed>
  801281:	85 c0                	test   %eax,%eax
  801283:	75 48                	jne    8012cd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801285:	e8 e0 ee ff ff       	call   80016a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80128a:	8b 43 04             	mov    0x4(%ebx),%eax
  80128d:	8b 0b                	mov    (%ebx),%ecx
  80128f:	8d 51 20             	lea    0x20(%ecx),%edx
  801292:	39 d0                	cmp    %edx,%eax
  801294:	73 e2                	jae    801278 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801299:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80129d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8012a0:	89 c2                	mov    %eax,%edx
  8012a2:	c1 fa 1f             	sar    $0x1f,%edx
  8012a5:	89 d1                	mov    %edx,%ecx
  8012a7:	c1 e9 1b             	shr    $0x1b,%ecx
  8012aa:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8012ad:	83 e2 1f             	and    $0x1f,%edx
  8012b0:	29 ca                	sub    %ecx,%edx
  8012b2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8012b6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8012ba:	83 c0 01             	add    $0x1,%eax
  8012bd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012c0:	83 c7 01             	add    $0x1,%edi
  8012c3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8012c6:	75 c2                	jne    80128a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8012c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8012cb:	eb 05                	jmp    8012d2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012cd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8012d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5e                   	pop    %esi
  8012d7:	5f                   	pop    %edi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	57                   	push   %edi
  8012de:	56                   	push   %esi
  8012df:	53                   	push   %ebx
  8012e0:	83 ec 18             	sub    $0x18,%esp
  8012e3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8012e6:	57                   	push   %edi
  8012e7:	e8 7a f6 ff ff       	call   800966 <fd2data>
  8012ec:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f6:	eb 3d                	jmp    801335 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8012f8:	85 db                	test   %ebx,%ebx
  8012fa:	74 04                	je     801300 <devpipe_read+0x26>
				return i;
  8012fc:	89 d8                	mov    %ebx,%eax
  8012fe:	eb 44                	jmp    801344 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801300:	89 f2                	mov    %esi,%edx
  801302:	89 f8                	mov    %edi,%eax
  801304:	e8 dc fe ff ff       	call   8011e5 <_pipeisclosed>
  801309:	85 c0                	test   %eax,%eax
  80130b:	75 32                	jne    80133f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80130d:	e8 58 ee ff ff       	call   80016a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801312:	8b 06                	mov    (%esi),%eax
  801314:	3b 46 04             	cmp    0x4(%esi),%eax
  801317:	74 df                	je     8012f8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801319:	99                   	cltd   
  80131a:	c1 ea 1b             	shr    $0x1b,%edx
  80131d:	01 d0                	add    %edx,%eax
  80131f:	83 e0 1f             	and    $0x1f,%eax
  801322:	29 d0                	sub    %edx,%eax
  801324:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801329:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80132f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801332:	83 c3 01             	add    $0x1,%ebx
  801335:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801338:	75 d8                	jne    801312 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80133a:	8b 45 10             	mov    0x10(%ebp),%eax
  80133d:	eb 05                	jmp    801344 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80133f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801344:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5f                   	pop    %edi
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    

0080134c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	56                   	push   %esi
  801350:	53                   	push   %ebx
  801351:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801354:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801357:	50                   	push   %eax
  801358:	e8 20 f6 ff ff       	call   80097d <fd_alloc>
  80135d:	83 c4 10             	add    $0x10,%esp
  801360:	89 c2                	mov    %eax,%edx
  801362:	85 c0                	test   %eax,%eax
  801364:	0f 88 2c 01 00 00    	js     801496 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80136a:	83 ec 04             	sub    $0x4,%esp
  80136d:	68 07 04 00 00       	push   $0x407
  801372:	ff 75 f4             	pushl  -0xc(%ebp)
  801375:	6a 00                	push   $0x0
  801377:	e8 0d ee ff ff       	call   800189 <sys_page_alloc>
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	89 c2                	mov    %eax,%edx
  801381:	85 c0                	test   %eax,%eax
  801383:	0f 88 0d 01 00 00    	js     801496 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801389:	83 ec 0c             	sub    $0xc,%esp
  80138c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	e8 e8 f5 ff ff       	call   80097d <fd_alloc>
  801395:	89 c3                	mov    %eax,%ebx
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	0f 88 e2 00 00 00    	js     801484 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013a2:	83 ec 04             	sub    $0x4,%esp
  8013a5:	68 07 04 00 00       	push   $0x407
  8013aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ad:	6a 00                	push   $0x0
  8013af:	e8 d5 ed ff ff       	call   800189 <sys_page_alloc>
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	85 c0                	test   %eax,%eax
  8013bb:	0f 88 c3 00 00 00    	js     801484 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8013c1:	83 ec 0c             	sub    $0xc,%esp
  8013c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c7:	e8 9a f5 ff ff       	call   800966 <fd2data>
  8013cc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013ce:	83 c4 0c             	add    $0xc,%esp
  8013d1:	68 07 04 00 00       	push   $0x407
  8013d6:	50                   	push   %eax
  8013d7:	6a 00                	push   $0x0
  8013d9:	e8 ab ed ff ff       	call   800189 <sys_page_alloc>
  8013de:	89 c3                	mov    %eax,%ebx
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	0f 88 89 00 00 00    	js     801474 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013eb:	83 ec 0c             	sub    $0xc,%esp
  8013ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8013f1:	e8 70 f5 ff ff       	call   800966 <fd2data>
  8013f6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8013fd:	50                   	push   %eax
  8013fe:	6a 00                	push   $0x0
  801400:	56                   	push   %esi
  801401:	6a 00                	push   $0x0
  801403:	e8 c4 ed ff ff       	call   8001cc <sys_page_map>
  801408:	89 c3                	mov    %eax,%ebx
  80140a:	83 c4 20             	add    $0x20,%esp
  80140d:	85 c0                	test   %eax,%eax
  80140f:	78 55                	js     801466 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801411:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801417:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80141c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801426:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80142c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801431:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801434:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80143b:	83 ec 0c             	sub    $0xc,%esp
  80143e:	ff 75 f4             	pushl  -0xc(%ebp)
  801441:	e8 10 f5 ff ff       	call   800956 <fd2num>
  801446:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801449:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80144b:	83 c4 04             	add    $0x4,%esp
  80144e:	ff 75 f0             	pushl  -0x10(%ebp)
  801451:	e8 00 f5 ff ff       	call   800956 <fd2num>
  801456:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801459:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	ba 00 00 00 00       	mov    $0x0,%edx
  801464:	eb 30                	jmp    801496 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801466:	83 ec 08             	sub    $0x8,%esp
  801469:	56                   	push   %esi
  80146a:	6a 00                	push   $0x0
  80146c:	e8 9d ed ff ff       	call   80020e <sys_page_unmap>
  801471:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	ff 75 f0             	pushl  -0x10(%ebp)
  80147a:	6a 00                	push   $0x0
  80147c:	e8 8d ed ff ff       	call   80020e <sys_page_unmap>
  801481:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801484:	83 ec 08             	sub    $0x8,%esp
  801487:	ff 75 f4             	pushl  -0xc(%ebp)
  80148a:	6a 00                	push   $0x0
  80148c:	e8 7d ed ff ff       	call   80020e <sys_page_unmap>
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801496:	89 d0                	mov    %edx,%eax
  801498:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149b:	5b                   	pop    %ebx
  80149c:	5e                   	pop    %esi
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    

0080149f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a8:	50                   	push   %eax
  8014a9:	ff 75 08             	pushl  0x8(%ebp)
  8014ac:	e8 1b f5 ff ff       	call   8009cc <fd_lookup>
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 18                	js     8014d0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8014b8:	83 ec 0c             	sub    $0xc,%esp
  8014bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8014be:	e8 a3 f4 ff ff       	call   800966 <fd2data>
	return _pipeisclosed(fd, p);
  8014c3:	89 c2                	mov    %eax,%edx
  8014c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c8:	e8 18 fd ff ff       	call   8011e5 <_pipeisclosed>
  8014cd:	83 c4 10             	add    $0x10,%esp
}
  8014d0:	c9                   	leave  
  8014d1:	c3                   	ret    

008014d2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8014d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    

008014dc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8014e2:	68 f2 26 80 00       	push   $0x8026f2
  8014e7:	ff 75 0c             	pushl  0xc(%ebp)
  8014ea:	e8 c4 07 00 00       	call   801cb3 <strcpy>
	return 0;
}
  8014ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f4:	c9                   	leave  
  8014f5:	c3                   	ret    

008014f6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	57                   	push   %edi
  8014fa:	56                   	push   %esi
  8014fb:	53                   	push   %ebx
  8014fc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801502:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801507:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80150d:	eb 2d                	jmp    80153c <devcons_write+0x46>
		m = n - tot;
  80150f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801512:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801514:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801517:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80151c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80151f:	83 ec 04             	sub    $0x4,%esp
  801522:	53                   	push   %ebx
  801523:	03 45 0c             	add    0xc(%ebp),%eax
  801526:	50                   	push   %eax
  801527:	57                   	push   %edi
  801528:	e8 18 09 00 00       	call   801e45 <memmove>
		sys_cputs(buf, m);
  80152d:	83 c4 08             	add    $0x8,%esp
  801530:	53                   	push   %ebx
  801531:	57                   	push   %edi
  801532:	e8 96 eb ff ff       	call   8000cd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801537:	01 de                	add    %ebx,%esi
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	89 f0                	mov    %esi,%eax
  80153e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801541:	72 cc                	jb     80150f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801543:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801546:	5b                   	pop    %ebx
  801547:	5e                   	pop    %esi
  801548:	5f                   	pop    %edi
  801549:	5d                   	pop    %ebp
  80154a:	c3                   	ret    

0080154b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801556:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80155a:	74 2a                	je     801586 <devcons_read+0x3b>
  80155c:	eb 05                	jmp    801563 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80155e:	e8 07 ec ff ff       	call   80016a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801563:	e8 83 eb ff ff       	call   8000eb <sys_cgetc>
  801568:	85 c0                	test   %eax,%eax
  80156a:	74 f2                	je     80155e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 16                	js     801586 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801570:	83 f8 04             	cmp    $0x4,%eax
  801573:	74 0c                	je     801581 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801575:	8b 55 0c             	mov    0xc(%ebp),%edx
  801578:	88 02                	mov    %al,(%edx)
	return 1;
  80157a:	b8 01 00 00 00       	mov    $0x1,%eax
  80157f:	eb 05                	jmp    801586 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801581:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801586:	c9                   	leave  
  801587:	c3                   	ret    

00801588 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80158e:	8b 45 08             	mov    0x8(%ebp),%eax
  801591:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801594:	6a 01                	push   $0x1
  801596:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	e8 2e eb ff ff       	call   8000cd <sys_cputs>
}
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	c9                   	leave  
  8015a3:	c3                   	ret    

008015a4 <getchar>:

int
getchar(void)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8015aa:	6a 01                	push   $0x1
  8015ac:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	6a 00                	push   $0x0
  8015b2:	e8 7e f6 ff ff       	call   800c35 <read>
	if (r < 0)
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 0f                	js     8015cd <getchar+0x29>
		return r;
	if (r < 1)
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	7e 06                	jle    8015c8 <getchar+0x24>
		return -E_EOF;
	return c;
  8015c2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8015c6:	eb 05                	jmp    8015cd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8015c8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	ff 75 08             	pushl  0x8(%ebp)
  8015dc:	e8 eb f3 ff ff       	call   8009cc <fd_lookup>
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 11                	js     8015f9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8015e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015eb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015f1:	39 10                	cmp    %edx,(%eax)
  8015f3:	0f 94 c0             	sete   %al
  8015f6:	0f b6 c0             	movzbl %al,%eax
}
  8015f9:	c9                   	leave  
  8015fa:	c3                   	ret    

008015fb <opencons>:

int
opencons(void)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801601:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801604:	50                   	push   %eax
  801605:	e8 73 f3 ff ff       	call   80097d <fd_alloc>
  80160a:	83 c4 10             	add    $0x10,%esp
		return r;
  80160d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 3e                	js     801651 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801613:	83 ec 04             	sub    $0x4,%esp
  801616:	68 07 04 00 00       	push   $0x407
  80161b:	ff 75 f4             	pushl  -0xc(%ebp)
  80161e:	6a 00                	push   $0x0
  801620:	e8 64 eb ff ff       	call   800189 <sys_page_alloc>
  801625:	83 c4 10             	add    $0x10,%esp
		return r;
  801628:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 23                	js     801651 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80162e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801634:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801637:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801639:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801643:	83 ec 0c             	sub    $0xc,%esp
  801646:	50                   	push   %eax
  801647:	e8 0a f3 ff ff       	call   800956 <fd2num>
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	83 c4 10             	add    $0x10,%esp
}
  801651:	89 d0                	mov    %edx,%eax
  801653:	c9                   	leave  
  801654:	c3                   	ret    

00801655 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	56                   	push   %esi
  801659:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80165a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80165d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801663:	e8 e3 ea ff ff       	call   80014b <sys_getenvid>
  801668:	83 ec 0c             	sub    $0xc,%esp
  80166b:	ff 75 0c             	pushl  0xc(%ebp)
  80166e:	ff 75 08             	pushl  0x8(%ebp)
  801671:	56                   	push   %esi
  801672:	50                   	push   %eax
  801673:	68 00 27 80 00       	push   $0x802700
  801678:	e8 b1 00 00 00       	call   80172e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80167d:	83 c4 18             	add    $0x18,%esp
  801680:	53                   	push   %ebx
  801681:	ff 75 10             	pushl  0x10(%ebp)
  801684:	e8 54 00 00 00       	call   8016dd <vcprintf>
	cprintf("\n");
  801689:	c7 04 24 51 25 80 00 	movl   $0x802551,(%esp)
  801690:	e8 99 00 00 00       	call   80172e <cprintf>
  801695:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801698:	cc                   	int3   
  801699:	eb fd                	jmp    801698 <_panic+0x43>

0080169b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	53                   	push   %ebx
  80169f:	83 ec 04             	sub    $0x4,%esp
  8016a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8016a5:	8b 13                	mov    (%ebx),%edx
  8016a7:	8d 42 01             	lea    0x1(%edx),%eax
  8016aa:	89 03                	mov    %eax,(%ebx)
  8016ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016af:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8016b3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8016b8:	75 1a                	jne    8016d4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8016ba:	83 ec 08             	sub    $0x8,%esp
  8016bd:	68 ff 00 00 00       	push   $0xff
  8016c2:	8d 43 08             	lea    0x8(%ebx),%eax
  8016c5:	50                   	push   %eax
  8016c6:	e8 02 ea ff ff       	call   8000cd <sys_cputs>
		b->idx = 0;
  8016cb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016d1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8016d4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8016d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016db:	c9                   	leave  
  8016dc:	c3                   	ret    

008016dd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8016e6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016ed:	00 00 00 
	b.cnt = 0;
  8016f0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8016f7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8016fa:	ff 75 0c             	pushl  0xc(%ebp)
  8016fd:	ff 75 08             	pushl  0x8(%ebp)
  801700:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801706:	50                   	push   %eax
  801707:	68 9b 16 80 00       	push   $0x80169b
  80170c:	e8 54 01 00 00       	call   801865 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801711:	83 c4 08             	add    $0x8,%esp
  801714:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80171a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801720:	50                   	push   %eax
  801721:	e8 a7 e9 ff ff       	call   8000cd <sys_cputs>

	return b.cnt;
}
  801726:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801734:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801737:	50                   	push   %eax
  801738:	ff 75 08             	pushl  0x8(%ebp)
  80173b:	e8 9d ff ff ff       	call   8016dd <vcprintf>
	va_end(ap);

	return cnt;
}
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	57                   	push   %edi
  801746:	56                   	push   %esi
  801747:	53                   	push   %ebx
  801748:	83 ec 1c             	sub    $0x1c,%esp
  80174b:	89 c7                	mov    %eax,%edi
  80174d:	89 d6                	mov    %edx,%esi
  80174f:	8b 45 08             	mov    0x8(%ebp),%eax
  801752:	8b 55 0c             	mov    0xc(%ebp),%edx
  801755:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801758:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80175b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80175e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801763:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801766:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801769:	39 d3                	cmp    %edx,%ebx
  80176b:	72 05                	jb     801772 <printnum+0x30>
  80176d:	39 45 10             	cmp    %eax,0x10(%ebp)
  801770:	77 45                	ja     8017b7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801772:	83 ec 0c             	sub    $0xc,%esp
  801775:	ff 75 18             	pushl  0x18(%ebp)
  801778:	8b 45 14             	mov    0x14(%ebp),%eax
  80177b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80177e:	53                   	push   %ebx
  80177f:	ff 75 10             	pushl  0x10(%ebp)
  801782:	83 ec 08             	sub    $0x8,%esp
  801785:	ff 75 e4             	pushl  -0x1c(%ebp)
  801788:	ff 75 e0             	pushl  -0x20(%ebp)
  80178b:	ff 75 dc             	pushl  -0x24(%ebp)
  80178e:	ff 75 d8             	pushl  -0x28(%ebp)
  801791:	e8 5a 0a 00 00       	call   8021f0 <__udivdi3>
  801796:	83 c4 18             	add    $0x18,%esp
  801799:	52                   	push   %edx
  80179a:	50                   	push   %eax
  80179b:	89 f2                	mov    %esi,%edx
  80179d:	89 f8                	mov    %edi,%eax
  80179f:	e8 9e ff ff ff       	call   801742 <printnum>
  8017a4:	83 c4 20             	add    $0x20,%esp
  8017a7:	eb 18                	jmp    8017c1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8017a9:	83 ec 08             	sub    $0x8,%esp
  8017ac:	56                   	push   %esi
  8017ad:	ff 75 18             	pushl  0x18(%ebp)
  8017b0:	ff d7                	call   *%edi
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	eb 03                	jmp    8017ba <printnum+0x78>
  8017b7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8017ba:	83 eb 01             	sub    $0x1,%ebx
  8017bd:	85 db                	test   %ebx,%ebx
  8017bf:	7f e8                	jg     8017a9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017c1:	83 ec 08             	sub    $0x8,%esp
  8017c4:	56                   	push   %esi
  8017c5:	83 ec 04             	sub    $0x4,%esp
  8017c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8017ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8017d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8017d4:	e8 47 0b 00 00       	call   802320 <__umoddi3>
  8017d9:	83 c4 14             	add    $0x14,%esp
  8017dc:	0f be 80 23 27 80 00 	movsbl 0x802723(%eax),%eax
  8017e3:	50                   	push   %eax
  8017e4:	ff d7                	call   *%edi
}
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ec:	5b                   	pop    %ebx
  8017ed:	5e                   	pop    %esi
  8017ee:	5f                   	pop    %edi
  8017ef:	5d                   	pop    %ebp
  8017f0:	c3                   	ret    

008017f1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8017f4:	83 fa 01             	cmp    $0x1,%edx
  8017f7:	7e 0e                	jle    801807 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8017f9:	8b 10                	mov    (%eax),%edx
  8017fb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8017fe:	89 08                	mov    %ecx,(%eax)
  801800:	8b 02                	mov    (%edx),%eax
  801802:	8b 52 04             	mov    0x4(%edx),%edx
  801805:	eb 22                	jmp    801829 <getuint+0x38>
	else if (lflag)
  801807:	85 d2                	test   %edx,%edx
  801809:	74 10                	je     80181b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80180b:	8b 10                	mov    (%eax),%edx
  80180d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801810:	89 08                	mov    %ecx,(%eax)
  801812:	8b 02                	mov    (%edx),%eax
  801814:	ba 00 00 00 00       	mov    $0x0,%edx
  801819:	eb 0e                	jmp    801829 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80181b:	8b 10                	mov    (%eax),%edx
  80181d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801820:	89 08                	mov    %ecx,(%eax)
  801822:	8b 02                	mov    (%edx),%eax
  801824:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801829:	5d                   	pop    %ebp
  80182a:	c3                   	ret    

0080182b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801831:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801835:	8b 10                	mov    (%eax),%edx
  801837:	3b 50 04             	cmp    0x4(%eax),%edx
  80183a:	73 0a                	jae    801846 <sprintputch+0x1b>
		*b->buf++ = ch;
  80183c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80183f:	89 08                	mov    %ecx,(%eax)
  801841:	8b 45 08             	mov    0x8(%ebp),%eax
  801844:	88 02                	mov    %al,(%edx)
}
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80184e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801851:	50                   	push   %eax
  801852:	ff 75 10             	pushl  0x10(%ebp)
  801855:	ff 75 0c             	pushl  0xc(%ebp)
  801858:	ff 75 08             	pushl  0x8(%ebp)
  80185b:	e8 05 00 00 00       	call   801865 <vprintfmt>
	va_end(ap);
}
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	c9                   	leave  
  801864:	c3                   	ret    

00801865 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	57                   	push   %edi
  801869:	56                   	push   %esi
  80186a:	53                   	push   %ebx
  80186b:	83 ec 2c             	sub    $0x2c,%esp
  80186e:	8b 75 08             	mov    0x8(%ebp),%esi
  801871:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801874:	8b 7d 10             	mov    0x10(%ebp),%edi
  801877:	eb 12                	jmp    80188b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801879:	85 c0                	test   %eax,%eax
  80187b:	0f 84 89 03 00 00    	je     801c0a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801881:	83 ec 08             	sub    $0x8,%esp
  801884:	53                   	push   %ebx
  801885:	50                   	push   %eax
  801886:	ff d6                	call   *%esi
  801888:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80188b:	83 c7 01             	add    $0x1,%edi
  80188e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801892:	83 f8 25             	cmp    $0x25,%eax
  801895:	75 e2                	jne    801879 <vprintfmt+0x14>
  801897:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80189b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8018a2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018a9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8018b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b5:	eb 07                	jmp    8018be <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8018ba:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018be:	8d 47 01             	lea    0x1(%edi),%eax
  8018c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018c4:	0f b6 07             	movzbl (%edi),%eax
  8018c7:	0f b6 c8             	movzbl %al,%ecx
  8018ca:	83 e8 23             	sub    $0x23,%eax
  8018cd:	3c 55                	cmp    $0x55,%al
  8018cf:	0f 87 1a 03 00 00    	ja     801bef <vprintfmt+0x38a>
  8018d5:	0f b6 c0             	movzbl %al,%eax
  8018d8:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  8018df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8018e2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8018e6:	eb d6                	jmp    8018be <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8018f3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8018f6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8018fa:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8018fd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801900:	83 fa 09             	cmp    $0x9,%edx
  801903:	77 39                	ja     80193e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801905:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801908:	eb e9                	jmp    8018f3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80190a:	8b 45 14             	mov    0x14(%ebp),%eax
  80190d:	8d 48 04             	lea    0x4(%eax),%ecx
  801910:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801913:	8b 00                	mov    (%eax),%eax
  801915:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801918:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80191b:	eb 27                	jmp    801944 <vprintfmt+0xdf>
  80191d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801920:	85 c0                	test   %eax,%eax
  801922:	b9 00 00 00 00       	mov    $0x0,%ecx
  801927:	0f 49 c8             	cmovns %eax,%ecx
  80192a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801930:	eb 8c                	jmp    8018be <vprintfmt+0x59>
  801932:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801935:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80193c:	eb 80                	jmp    8018be <vprintfmt+0x59>
  80193e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801941:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801944:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801948:	0f 89 70 ff ff ff    	jns    8018be <vprintfmt+0x59>
				width = precision, precision = -1;
  80194e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801951:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801954:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80195b:	e9 5e ff ff ff       	jmp    8018be <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801960:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801963:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801966:	e9 53 ff ff ff       	jmp    8018be <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80196b:	8b 45 14             	mov    0x14(%ebp),%eax
  80196e:	8d 50 04             	lea    0x4(%eax),%edx
  801971:	89 55 14             	mov    %edx,0x14(%ebp)
  801974:	83 ec 08             	sub    $0x8,%esp
  801977:	53                   	push   %ebx
  801978:	ff 30                	pushl  (%eax)
  80197a:	ff d6                	call   *%esi
			break;
  80197c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80197f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801982:	e9 04 ff ff ff       	jmp    80188b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801987:	8b 45 14             	mov    0x14(%ebp),%eax
  80198a:	8d 50 04             	lea    0x4(%eax),%edx
  80198d:	89 55 14             	mov    %edx,0x14(%ebp)
  801990:	8b 00                	mov    (%eax),%eax
  801992:	99                   	cltd   
  801993:	31 d0                	xor    %edx,%eax
  801995:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801997:	83 f8 0f             	cmp    $0xf,%eax
  80199a:	7f 0b                	jg     8019a7 <vprintfmt+0x142>
  80199c:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  8019a3:	85 d2                	test   %edx,%edx
  8019a5:	75 18                	jne    8019bf <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8019a7:	50                   	push   %eax
  8019a8:	68 3b 27 80 00       	push   $0x80273b
  8019ad:	53                   	push   %ebx
  8019ae:	56                   	push   %esi
  8019af:	e8 94 fe ff ff       	call   801848 <printfmt>
  8019b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8019ba:	e9 cc fe ff ff       	jmp    80188b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8019bf:	52                   	push   %edx
  8019c0:	68 b9 26 80 00       	push   $0x8026b9
  8019c5:	53                   	push   %ebx
  8019c6:	56                   	push   %esi
  8019c7:	e8 7c fe ff ff       	call   801848 <printfmt>
  8019cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019d2:	e9 b4 fe ff ff       	jmp    80188b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8019d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019da:	8d 50 04             	lea    0x4(%eax),%edx
  8019dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8019e0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8019e2:	85 ff                	test   %edi,%edi
  8019e4:	b8 34 27 80 00       	mov    $0x802734,%eax
  8019e9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8019ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8019f0:	0f 8e 94 00 00 00    	jle    801a8a <vprintfmt+0x225>
  8019f6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8019fa:	0f 84 98 00 00 00    	je     801a98 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801a00:	83 ec 08             	sub    $0x8,%esp
  801a03:	ff 75 d0             	pushl  -0x30(%ebp)
  801a06:	57                   	push   %edi
  801a07:	e8 86 02 00 00       	call   801c92 <strnlen>
  801a0c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801a0f:	29 c1                	sub    %eax,%ecx
  801a11:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801a14:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801a17:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801a1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a1e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801a21:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a23:	eb 0f                	jmp    801a34 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801a25:	83 ec 08             	sub    $0x8,%esp
  801a28:	53                   	push   %ebx
  801a29:	ff 75 e0             	pushl  -0x20(%ebp)
  801a2c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a2e:	83 ef 01             	sub    $0x1,%edi
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	85 ff                	test   %edi,%edi
  801a36:	7f ed                	jg     801a25 <vprintfmt+0x1c0>
  801a38:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801a3b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801a3e:	85 c9                	test   %ecx,%ecx
  801a40:	b8 00 00 00 00       	mov    $0x0,%eax
  801a45:	0f 49 c1             	cmovns %ecx,%eax
  801a48:	29 c1                	sub    %eax,%ecx
  801a4a:	89 75 08             	mov    %esi,0x8(%ebp)
  801a4d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a50:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a53:	89 cb                	mov    %ecx,%ebx
  801a55:	eb 4d                	jmp    801aa4 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a57:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a5b:	74 1b                	je     801a78 <vprintfmt+0x213>
  801a5d:	0f be c0             	movsbl %al,%eax
  801a60:	83 e8 20             	sub    $0x20,%eax
  801a63:	83 f8 5e             	cmp    $0x5e,%eax
  801a66:	76 10                	jbe    801a78 <vprintfmt+0x213>
					putch('?', putdat);
  801a68:	83 ec 08             	sub    $0x8,%esp
  801a6b:	ff 75 0c             	pushl  0xc(%ebp)
  801a6e:	6a 3f                	push   $0x3f
  801a70:	ff 55 08             	call   *0x8(%ebp)
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	eb 0d                	jmp    801a85 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801a78:	83 ec 08             	sub    $0x8,%esp
  801a7b:	ff 75 0c             	pushl  0xc(%ebp)
  801a7e:	52                   	push   %edx
  801a7f:	ff 55 08             	call   *0x8(%ebp)
  801a82:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a85:	83 eb 01             	sub    $0x1,%ebx
  801a88:	eb 1a                	jmp    801aa4 <vprintfmt+0x23f>
  801a8a:	89 75 08             	mov    %esi,0x8(%ebp)
  801a8d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a90:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a93:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a96:	eb 0c                	jmp    801aa4 <vprintfmt+0x23f>
  801a98:	89 75 08             	mov    %esi,0x8(%ebp)
  801a9b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a9e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801aa1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801aa4:	83 c7 01             	add    $0x1,%edi
  801aa7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801aab:	0f be d0             	movsbl %al,%edx
  801aae:	85 d2                	test   %edx,%edx
  801ab0:	74 23                	je     801ad5 <vprintfmt+0x270>
  801ab2:	85 f6                	test   %esi,%esi
  801ab4:	78 a1                	js     801a57 <vprintfmt+0x1f2>
  801ab6:	83 ee 01             	sub    $0x1,%esi
  801ab9:	79 9c                	jns    801a57 <vprintfmt+0x1f2>
  801abb:	89 df                	mov    %ebx,%edi
  801abd:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ac3:	eb 18                	jmp    801add <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801ac5:	83 ec 08             	sub    $0x8,%esp
  801ac8:	53                   	push   %ebx
  801ac9:	6a 20                	push   $0x20
  801acb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801acd:	83 ef 01             	sub    $0x1,%edi
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	eb 08                	jmp    801add <vprintfmt+0x278>
  801ad5:	89 df                	mov    %ebx,%edi
  801ad7:	8b 75 08             	mov    0x8(%ebp),%esi
  801ada:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801add:	85 ff                	test   %edi,%edi
  801adf:	7f e4                	jg     801ac5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ae1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ae4:	e9 a2 fd ff ff       	jmp    80188b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801ae9:	83 fa 01             	cmp    $0x1,%edx
  801aec:	7e 16                	jle    801b04 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801aee:	8b 45 14             	mov    0x14(%ebp),%eax
  801af1:	8d 50 08             	lea    0x8(%eax),%edx
  801af4:	89 55 14             	mov    %edx,0x14(%ebp)
  801af7:	8b 50 04             	mov    0x4(%eax),%edx
  801afa:	8b 00                	mov    (%eax),%eax
  801afc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aff:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801b02:	eb 32                	jmp    801b36 <vprintfmt+0x2d1>
	else if (lflag)
  801b04:	85 d2                	test   %edx,%edx
  801b06:	74 18                	je     801b20 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801b08:	8b 45 14             	mov    0x14(%ebp),%eax
  801b0b:	8d 50 04             	lea    0x4(%eax),%edx
  801b0e:	89 55 14             	mov    %edx,0x14(%ebp)
  801b11:	8b 00                	mov    (%eax),%eax
  801b13:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b16:	89 c1                	mov    %eax,%ecx
  801b18:	c1 f9 1f             	sar    $0x1f,%ecx
  801b1b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801b1e:	eb 16                	jmp    801b36 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801b20:	8b 45 14             	mov    0x14(%ebp),%eax
  801b23:	8d 50 04             	lea    0x4(%eax),%edx
  801b26:	89 55 14             	mov    %edx,0x14(%ebp)
  801b29:	8b 00                	mov    (%eax),%eax
  801b2b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b2e:	89 c1                	mov    %eax,%ecx
  801b30:	c1 f9 1f             	sar    $0x1f,%ecx
  801b33:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801b36:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b39:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801b3c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801b41:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b45:	79 74                	jns    801bbb <vprintfmt+0x356>
				putch('-', putdat);
  801b47:	83 ec 08             	sub    $0x8,%esp
  801b4a:	53                   	push   %ebx
  801b4b:	6a 2d                	push   $0x2d
  801b4d:	ff d6                	call   *%esi
				num = -(long long) num;
  801b4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b52:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b55:	f7 d8                	neg    %eax
  801b57:	83 d2 00             	adc    $0x0,%edx
  801b5a:	f7 da                	neg    %edx
  801b5c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801b5f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801b64:	eb 55                	jmp    801bbb <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b66:	8d 45 14             	lea    0x14(%ebp),%eax
  801b69:	e8 83 fc ff ff       	call   8017f1 <getuint>
			base = 10;
  801b6e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801b73:	eb 46                	jmp    801bbb <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801b75:	8d 45 14             	lea    0x14(%ebp),%eax
  801b78:	e8 74 fc ff ff       	call   8017f1 <getuint>
			base = 8;
  801b7d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b82:	eb 37                	jmp    801bbb <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b84:	83 ec 08             	sub    $0x8,%esp
  801b87:	53                   	push   %ebx
  801b88:	6a 30                	push   $0x30
  801b8a:	ff d6                	call   *%esi
			putch('x', putdat);
  801b8c:	83 c4 08             	add    $0x8,%esp
  801b8f:	53                   	push   %ebx
  801b90:	6a 78                	push   $0x78
  801b92:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b94:	8b 45 14             	mov    0x14(%ebp),%eax
  801b97:	8d 50 04             	lea    0x4(%eax),%edx
  801b9a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b9d:	8b 00                	mov    (%eax),%eax
  801b9f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ba4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ba7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801bac:	eb 0d                	jmp    801bbb <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801bae:	8d 45 14             	lea    0x14(%ebp),%eax
  801bb1:	e8 3b fc ff ff       	call   8017f1 <getuint>
			base = 16;
  801bb6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801bbb:	83 ec 0c             	sub    $0xc,%esp
  801bbe:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801bc2:	57                   	push   %edi
  801bc3:	ff 75 e0             	pushl  -0x20(%ebp)
  801bc6:	51                   	push   %ecx
  801bc7:	52                   	push   %edx
  801bc8:	50                   	push   %eax
  801bc9:	89 da                	mov    %ebx,%edx
  801bcb:	89 f0                	mov    %esi,%eax
  801bcd:	e8 70 fb ff ff       	call   801742 <printnum>
			break;
  801bd2:	83 c4 20             	add    $0x20,%esp
  801bd5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bd8:	e9 ae fc ff ff       	jmp    80188b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801bdd:	83 ec 08             	sub    $0x8,%esp
  801be0:	53                   	push   %ebx
  801be1:	51                   	push   %ecx
  801be2:	ff d6                	call   *%esi
			break;
  801be4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801be7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801bea:	e9 9c fc ff ff       	jmp    80188b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801bef:	83 ec 08             	sub    $0x8,%esp
  801bf2:	53                   	push   %ebx
  801bf3:	6a 25                	push   $0x25
  801bf5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801bf7:	83 c4 10             	add    $0x10,%esp
  801bfa:	eb 03                	jmp    801bff <vprintfmt+0x39a>
  801bfc:	83 ef 01             	sub    $0x1,%edi
  801bff:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801c03:	75 f7                	jne    801bfc <vprintfmt+0x397>
  801c05:	e9 81 fc ff ff       	jmp    80188b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801c0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5f                   	pop    %edi
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    

00801c12 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	83 ec 18             	sub    $0x18,%esp
  801c18:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801c1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c21:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801c25:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	74 26                	je     801c59 <vsnprintf+0x47>
  801c33:	85 d2                	test   %edx,%edx
  801c35:	7e 22                	jle    801c59 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801c37:	ff 75 14             	pushl  0x14(%ebp)
  801c3a:	ff 75 10             	pushl  0x10(%ebp)
  801c3d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c40:	50                   	push   %eax
  801c41:	68 2b 18 80 00       	push   $0x80182b
  801c46:	e8 1a fc ff ff       	call   801865 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801c4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c4e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	eb 05                	jmp    801c5e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801c5e:	c9                   	leave  
  801c5f:	c3                   	ret    

00801c60 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c66:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c69:	50                   	push   %eax
  801c6a:	ff 75 10             	pushl  0x10(%ebp)
  801c6d:	ff 75 0c             	pushl  0xc(%ebp)
  801c70:	ff 75 08             	pushl  0x8(%ebp)
  801c73:	e8 9a ff ff ff       	call   801c12 <vsnprintf>
	va_end(ap);

	return rc;
}
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    

00801c7a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c80:	b8 00 00 00 00       	mov    $0x0,%eax
  801c85:	eb 03                	jmp    801c8a <strlen+0x10>
		n++;
  801c87:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c8a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c8e:	75 f7                	jne    801c87 <strlen+0xd>
		n++;
	return n;
}
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    

00801c92 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c92:	55                   	push   %ebp
  801c93:	89 e5                	mov    %esp,%ebp
  801c95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c98:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca0:	eb 03                	jmp    801ca5 <strnlen+0x13>
		n++;
  801ca2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ca5:	39 c2                	cmp    %eax,%edx
  801ca7:	74 08                	je     801cb1 <strnlen+0x1f>
  801ca9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801cad:	75 f3                	jne    801ca2 <strnlen+0x10>
  801caf:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801cb1:	5d                   	pop    %ebp
  801cb2:	c3                   	ret    

00801cb3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	53                   	push   %ebx
  801cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801cbd:	89 c2                	mov    %eax,%edx
  801cbf:	83 c2 01             	add    $0x1,%edx
  801cc2:	83 c1 01             	add    $0x1,%ecx
  801cc5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801cc9:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ccc:	84 db                	test   %bl,%bl
  801cce:	75 ef                	jne    801cbf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801cd0:	5b                   	pop    %ebx
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    

00801cd3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	53                   	push   %ebx
  801cd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801cda:	53                   	push   %ebx
  801cdb:	e8 9a ff ff ff       	call   801c7a <strlen>
  801ce0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801ce3:	ff 75 0c             	pushl  0xc(%ebp)
  801ce6:	01 d8                	add    %ebx,%eax
  801ce8:	50                   	push   %eax
  801ce9:	e8 c5 ff ff ff       	call   801cb3 <strcpy>
	return dst;
}
  801cee:	89 d8                	mov    %ebx,%eax
  801cf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf3:	c9                   	leave  
  801cf4:	c3                   	ret    

00801cf5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	56                   	push   %esi
  801cf9:	53                   	push   %ebx
  801cfa:	8b 75 08             	mov    0x8(%ebp),%esi
  801cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d00:	89 f3                	mov    %esi,%ebx
  801d02:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d05:	89 f2                	mov    %esi,%edx
  801d07:	eb 0f                	jmp    801d18 <strncpy+0x23>
		*dst++ = *src;
  801d09:	83 c2 01             	add    $0x1,%edx
  801d0c:	0f b6 01             	movzbl (%ecx),%eax
  801d0f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801d12:	80 39 01             	cmpb   $0x1,(%ecx)
  801d15:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d18:	39 da                	cmp    %ebx,%edx
  801d1a:	75 ed                	jne    801d09 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801d1c:	89 f0                	mov    %esi,%eax
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    

00801d22 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	56                   	push   %esi
  801d26:	53                   	push   %ebx
  801d27:	8b 75 08             	mov    0x8(%ebp),%esi
  801d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d2d:	8b 55 10             	mov    0x10(%ebp),%edx
  801d30:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801d32:	85 d2                	test   %edx,%edx
  801d34:	74 21                	je     801d57 <strlcpy+0x35>
  801d36:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801d3a:	89 f2                	mov    %esi,%edx
  801d3c:	eb 09                	jmp    801d47 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801d3e:	83 c2 01             	add    $0x1,%edx
  801d41:	83 c1 01             	add    $0x1,%ecx
  801d44:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801d47:	39 c2                	cmp    %eax,%edx
  801d49:	74 09                	je     801d54 <strlcpy+0x32>
  801d4b:	0f b6 19             	movzbl (%ecx),%ebx
  801d4e:	84 db                	test   %bl,%bl
  801d50:	75 ec                	jne    801d3e <strlcpy+0x1c>
  801d52:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801d54:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801d57:	29 f0                	sub    %esi,%eax
}
  801d59:	5b                   	pop    %ebx
  801d5a:	5e                   	pop    %esi
  801d5b:	5d                   	pop    %ebp
  801d5c:	c3                   	ret    

00801d5d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d63:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801d66:	eb 06                	jmp    801d6e <strcmp+0x11>
		p++, q++;
  801d68:	83 c1 01             	add    $0x1,%ecx
  801d6b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801d6e:	0f b6 01             	movzbl (%ecx),%eax
  801d71:	84 c0                	test   %al,%al
  801d73:	74 04                	je     801d79 <strcmp+0x1c>
  801d75:	3a 02                	cmp    (%edx),%al
  801d77:	74 ef                	je     801d68 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801d79:	0f b6 c0             	movzbl %al,%eax
  801d7c:	0f b6 12             	movzbl (%edx),%edx
  801d7f:	29 d0                	sub    %edx,%eax
}
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    

00801d83 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	53                   	push   %ebx
  801d87:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8d:	89 c3                	mov    %eax,%ebx
  801d8f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d92:	eb 06                	jmp    801d9a <strncmp+0x17>
		n--, p++, q++;
  801d94:	83 c0 01             	add    $0x1,%eax
  801d97:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d9a:	39 d8                	cmp    %ebx,%eax
  801d9c:	74 15                	je     801db3 <strncmp+0x30>
  801d9e:	0f b6 08             	movzbl (%eax),%ecx
  801da1:	84 c9                	test   %cl,%cl
  801da3:	74 04                	je     801da9 <strncmp+0x26>
  801da5:	3a 0a                	cmp    (%edx),%cl
  801da7:	74 eb                	je     801d94 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801da9:	0f b6 00             	movzbl (%eax),%eax
  801dac:	0f b6 12             	movzbl (%edx),%edx
  801daf:	29 d0                	sub    %edx,%eax
  801db1:	eb 05                	jmp    801db8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801db3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801db8:	5b                   	pop    %ebx
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801dc5:	eb 07                	jmp    801dce <strchr+0x13>
		if (*s == c)
  801dc7:	38 ca                	cmp    %cl,%dl
  801dc9:	74 0f                	je     801dda <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801dcb:	83 c0 01             	add    $0x1,%eax
  801dce:	0f b6 10             	movzbl (%eax),%edx
  801dd1:	84 d2                	test   %dl,%dl
  801dd3:	75 f2                	jne    801dc7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801dd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    

00801ddc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  801de2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801de6:	eb 03                	jmp    801deb <strfind+0xf>
  801de8:	83 c0 01             	add    $0x1,%eax
  801deb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801dee:	38 ca                	cmp    %cl,%dl
  801df0:	74 04                	je     801df6 <strfind+0x1a>
  801df2:	84 d2                	test   %dl,%dl
  801df4:	75 f2                	jne    801de8 <strfind+0xc>
			break;
	return (char *) s;
}
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    

00801df8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	57                   	push   %edi
  801dfc:	56                   	push   %esi
  801dfd:	53                   	push   %ebx
  801dfe:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e01:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801e04:	85 c9                	test   %ecx,%ecx
  801e06:	74 36                	je     801e3e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801e08:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801e0e:	75 28                	jne    801e38 <memset+0x40>
  801e10:	f6 c1 03             	test   $0x3,%cl
  801e13:	75 23                	jne    801e38 <memset+0x40>
		c &= 0xFF;
  801e15:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801e19:	89 d3                	mov    %edx,%ebx
  801e1b:	c1 e3 08             	shl    $0x8,%ebx
  801e1e:	89 d6                	mov    %edx,%esi
  801e20:	c1 e6 18             	shl    $0x18,%esi
  801e23:	89 d0                	mov    %edx,%eax
  801e25:	c1 e0 10             	shl    $0x10,%eax
  801e28:	09 f0                	or     %esi,%eax
  801e2a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801e2c:	89 d8                	mov    %ebx,%eax
  801e2e:	09 d0                	or     %edx,%eax
  801e30:	c1 e9 02             	shr    $0x2,%ecx
  801e33:	fc                   	cld    
  801e34:	f3 ab                	rep stos %eax,%es:(%edi)
  801e36:	eb 06                	jmp    801e3e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801e38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3b:	fc                   	cld    
  801e3c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801e3e:	89 f8                	mov    %edi,%eax
  801e40:	5b                   	pop    %ebx
  801e41:	5e                   	pop    %esi
  801e42:	5f                   	pop    %edi
  801e43:	5d                   	pop    %ebp
  801e44:	c3                   	ret    

00801e45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	57                   	push   %edi
  801e49:	56                   	push   %esi
  801e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e50:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e53:	39 c6                	cmp    %eax,%esi
  801e55:	73 35                	jae    801e8c <memmove+0x47>
  801e57:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e5a:	39 d0                	cmp    %edx,%eax
  801e5c:	73 2e                	jae    801e8c <memmove+0x47>
		s += n;
		d += n;
  801e5e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e61:	89 d6                	mov    %edx,%esi
  801e63:	09 fe                	or     %edi,%esi
  801e65:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e6b:	75 13                	jne    801e80 <memmove+0x3b>
  801e6d:	f6 c1 03             	test   $0x3,%cl
  801e70:	75 0e                	jne    801e80 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801e72:	83 ef 04             	sub    $0x4,%edi
  801e75:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e78:	c1 e9 02             	shr    $0x2,%ecx
  801e7b:	fd                   	std    
  801e7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e7e:	eb 09                	jmp    801e89 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e80:	83 ef 01             	sub    $0x1,%edi
  801e83:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e86:	fd                   	std    
  801e87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e89:	fc                   	cld    
  801e8a:	eb 1d                	jmp    801ea9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e8c:	89 f2                	mov    %esi,%edx
  801e8e:	09 c2                	or     %eax,%edx
  801e90:	f6 c2 03             	test   $0x3,%dl
  801e93:	75 0f                	jne    801ea4 <memmove+0x5f>
  801e95:	f6 c1 03             	test   $0x3,%cl
  801e98:	75 0a                	jne    801ea4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e9a:	c1 e9 02             	shr    $0x2,%ecx
  801e9d:	89 c7                	mov    %eax,%edi
  801e9f:	fc                   	cld    
  801ea0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801ea2:	eb 05                	jmp    801ea9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801ea4:	89 c7                	mov    %eax,%edi
  801ea6:	fc                   	cld    
  801ea7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801ea9:	5e                   	pop    %esi
  801eaa:	5f                   	pop    %edi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    

00801ead <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801eb0:	ff 75 10             	pushl  0x10(%ebp)
  801eb3:	ff 75 0c             	pushl  0xc(%ebp)
  801eb6:	ff 75 08             	pushl  0x8(%ebp)
  801eb9:	e8 87 ff ff ff       	call   801e45 <memmove>
}
  801ebe:	c9                   	leave  
  801ebf:	c3                   	ret    

00801ec0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	56                   	push   %esi
  801ec4:	53                   	push   %ebx
  801ec5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ecb:	89 c6                	mov    %eax,%esi
  801ecd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ed0:	eb 1a                	jmp    801eec <memcmp+0x2c>
		if (*s1 != *s2)
  801ed2:	0f b6 08             	movzbl (%eax),%ecx
  801ed5:	0f b6 1a             	movzbl (%edx),%ebx
  801ed8:	38 d9                	cmp    %bl,%cl
  801eda:	74 0a                	je     801ee6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801edc:	0f b6 c1             	movzbl %cl,%eax
  801edf:	0f b6 db             	movzbl %bl,%ebx
  801ee2:	29 d8                	sub    %ebx,%eax
  801ee4:	eb 0f                	jmp    801ef5 <memcmp+0x35>
		s1++, s2++;
  801ee6:	83 c0 01             	add    $0x1,%eax
  801ee9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801eec:	39 f0                	cmp    %esi,%eax
  801eee:	75 e2                	jne    801ed2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801ef0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ef5:	5b                   	pop    %ebx
  801ef6:	5e                   	pop    %esi
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    

00801ef9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	53                   	push   %ebx
  801efd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801f00:	89 c1                	mov    %eax,%ecx
  801f02:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801f05:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f09:	eb 0a                	jmp    801f15 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801f0b:	0f b6 10             	movzbl (%eax),%edx
  801f0e:	39 da                	cmp    %ebx,%edx
  801f10:	74 07                	je     801f19 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f12:	83 c0 01             	add    $0x1,%eax
  801f15:	39 c8                	cmp    %ecx,%eax
  801f17:	72 f2                	jb     801f0b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801f19:	5b                   	pop    %ebx
  801f1a:	5d                   	pop    %ebp
  801f1b:	c3                   	ret    

00801f1c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	57                   	push   %edi
  801f20:	56                   	push   %esi
  801f21:	53                   	push   %ebx
  801f22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f28:	eb 03                	jmp    801f2d <strtol+0x11>
		s++;
  801f2a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f2d:	0f b6 01             	movzbl (%ecx),%eax
  801f30:	3c 20                	cmp    $0x20,%al
  801f32:	74 f6                	je     801f2a <strtol+0xe>
  801f34:	3c 09                	cmp    $0x9,%al
  801f36:	74 f2                	je     801f2a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801f38:	3c 2b                	cmp    $0x2b,%al
  801f3a:	75 0a                	jne    801f46 <strtol+0x2a>
		s++;
  801f3c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801f3f:	bf 00 00 00 00       	mov    $0x0,%edi
  801f44:	eb 11                	jmp    801f57 <strtol+0x3b>
  801f46:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801f4b:	3c 2d                	cmp    $0x2d,%al
  801f4d:	75 08                	jne    801f57 <strtol+0x3b>
		s++, neg = 1;
  801f4f:	83 c1 01             	add    $0x1,%ecx
  801f52:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f57:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f5d:	75 15                	jne    801f74 <strtol+0x58>
  801f5f:	80 39 30             	cmpb   $0x30,(%ecx)
  801f62:	75 10                	jne    801f74 <strtol+0x58>
  801f64:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f68:	75 7c                	jne    801fe6 <strtol+0xca>
		s += 2, base = 16;
  801f6a:	83 c1 02             	add    $0x2,%ecx
  801f6d:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f72:	eb 16                	jmp    801f8a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801f74:	85 db                	test   %ebx,%ebx
  801f76:	75 12                	jne    801f8a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f78:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f7d:	80 39 30             	cmpb   $0x30,(%ecx)
  801f80:	75 08                	jne    801f8a <strtol+0x6e>
		s++, base = 8;
  801f82:	83 c1 01             	add    $0x1,%ecx
  801f85:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f92:	0f b6 11             	movzbl (%ecx),%edx
  801f95:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f98:	89 f3                	mov    %esi,%ebx
  801f9a:	80 fb 09             	cmp    $0x9,%bl
  801f9d:	77 08                	ja     801fa7 <strtol+0x8b>
			dig = *s - '0';
  801f9f:	0f be d2             	movsbl %dl,%edx
  801fa2:	83 ea 30             	sub    $0x30,%edx
  801fa5:	eb 22                	jmp    801fc9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801fa7:	8d 72 9f             	lea    -0x61(%edx),%esi
  801faa:	89 f3                	mov    %esi,%ebx
  801fac:	80 fb 19             	cmp    $0x19,%bl
  801faf:	77 08                	ja     801fb9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801fb1:	0f be d2             	movsbl %dl,%edx
  801fb4:	83 ea 57             	sub    $0x57,%edx
  801fb7:	eb 10                	jmp    801fc9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801fb9:	8d 72 bf             	lea    -0x41(%edx),%esi
  801fbc:	89 f3                	mov    %esi,%ebx
  801fbe:	80 fb 19             	cmp    $0x19,%bl
  801fc1:	77 16                	ja     801fd9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801fc3:	0f be d2             	movsbl %dl,%edx
  801fc6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801fc9:	3b 55 10             	cmp    0x10(%ebp),%edx
  801fcc:	7d 0b                	jge    801fd9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801fce:	83 c1 01             	add    $0x1,%ecx
  801fd1:	0f af 45 10          	imul   0x10(%ebp),%eax
  801fd5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801fd7:	eb b9                	jmp    801f92 <strtol+0x76>

	if (endptr)
  801fd9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801fdd:	74 0d                	je     801fec <strtol+0xd0>
		*endptr = (char *) s;
  801fdf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fe2:	89 0e                	mov    %ecx,(%esi)
  801fe4:	eb 06                	jmp    801fec <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801fe6:	85 db                	test   %ebx,%ebx
  801fe8:	74 98                	je     801f82 <strtol+0x66>
  801fea:	eb 9e                	jmp    801f8a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801fec:	89 c2                	mov    %eax,%edx
  801fee:	f7 da                	neg    %edx
  801ff0:	85 ff                	test   %edi,%edi
  801ff2:	0f 45 c2             	cmovne %edx,%eax
}
  801ff5:	5b                   	pop    %ebx
  801ff6:	5e                   	pop    %esi
  801ff7:	5f                   	pop    %edi
  801ff8:	5d                   	pop    %ebp
  801ff9:	c3                   	ret    

00801ffa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802000:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802007:	75 2a                	jne    802033 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802009:	83 ec 04             	sub    $0x4,%esp
  80200c:	6a 07                	push   $0x7
  80200e:	68 00 f0 bf ee       	push   $0xeebff000
  802013:	6a 00                	push   $0x0
  802015:	e8 6f e1 ff ff       	call   800189 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80201a:	83 c4 10             	add    $0x10,%esp
  80201d:	85 c0                	test   %eax,%eax
  80201f:	79 12                	jns    802033 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802021:	50                   	push   %eax
  802022:	68 83 25 80 00       	push   $0x802583
  802027:	6a 23                	push   $0x23
  802029:	68 20 2a 80 00       	push   $0x802a20
  80202e:	e8 22 f6 ff ff       	call   801655 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802033:	8b 45 08             	mov    0x8(%ebp),%eax
  802036:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80203b:	83 ec 08             	sub    $0x8,%esp
  80203e:	68 65 20 80 00       	push   $0x802065
  802043:	6a 00                	push   $0x0
  802045:	e8 8a e2 ff ff       	call   8002d4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80204a:	83 c4 10             	add    $0x10,%esp
  80204d:	85 c0                	test   %eax,%eax
  80204f:	79 12                	jns    802063 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802051:	50                   	push   %eax
  802052:	68 83 25 80 00       	push   $0x802583
  802057:	6a 2c                	push   $0x2c
  802059:	68 20 2a 80 00       	push   $0x802a20
  80205e:	e8 f2 f5 ff ff       	call   801655 <_panic>
	}
}
  802063:	c9                   	leave  
  802064:	c3                   	ret    

00802065 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802065:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802066:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80206b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80206d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802070:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802074:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802079:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80207d:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80207f:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802082:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802083:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802086:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802087:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802088:	c3                   	ret    

00802089 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	56                   	push   %esi
  80208d:	53                   	push   %ebx
  80208e:	8b 75 08             	mov    0x8(%ebp),%esi
  802091:	8b 45 0c             	mov    0xc(%ebp),%eax
  802094:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802097:	85 c0                	test   %eax,%eax
  802099:	75 12                	jne    8020ad <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80209b:	83 ec 0c             	sub    $0xc,%esp
  80209e:	68 00 00 c0 ee       	push   $0xeec00000
  8020a3:	e8 91 e2 ff ff       	call   800339 <sys_ipc_recv>
  8020a8:	83 c4 10             	add    $0x10,%esp
  8020ab:	eb 0c                	jmp    8020b9 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020ad:	83 ec 0c             	sub    $0xc,%esp
  8020b0:	50                   	push   %eax
  8020b1:	e8 83 e2 ff ff       	call   800339 <sys_ipc_recv>
  8020b6:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020b9:	85 f6                	test   %esi,%esi
  8020bb:	0f 95 c1             	setne  %cl
  8020be:	85 db                	test   %ebx,%ebx
  8020c0:	0f 95 c2             	setne  %dl
  8020c3:	84 d1                	test   %dl,%cl
  8020c5:	74 09                	je     8020d0 <ipc_recv+0x47>
  8020c7:	89 c2                	mov    %eax,%edx
  8020c9:	c1 ea 1f             	shr    $0x1f,%edx
  8020cc:	84 d2                	test   %dl,%dl
  8020ce:	75 2d                	jne    8020fd <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020d0:	85 f6                	test   %esi,%esi
  8020d2:	74 0d                	je     8020e1 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020d4:	a1 04 40 80 00       	mov    0x804004,%eax
  8020d9:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020df:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020e1:	85 db                	test   %ebx,%ebx
  8020e3:	74 0d                	je     8020f2 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020e5:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ea:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8020f0:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f7:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8020fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802100:	5b                   	pop    %ebx
  802101:	5e                   	pop    %esi
  802102:	5d                   	pop    %ebp
  802103:	c3                   	ret    

00802104 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	57                   	push   %edi
  802108:	56                   	push   %esi
  802109:	53                   	push   %ebx
  80210a:	83 ec 0c             	sub    $0xc,%esp
  80210d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802110:	8b 75 0c             	mov    0xc(%ebp),%esi
  802113:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802116:	85 db                	test   %ebx,%ebx
  802118:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80211d:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802120:	ff 75 14             	pushl  0x14(%ebp)
  802123:	53                   	push   %ebx
  802124:	56                   	push   %esi
  802125:	57                   	push   %edi
  802126:	e8 eb e1 ff ff       	call   800316 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80212b:	89 c2                	mov    %eax,%edx
  80212d:	c1 ea 1f             	shr    $0x1f,%edx
  802130:	83 c4 10             	add    $0x10,%esp
  802133:	84 d2                	test   %dl,%dl
  802135:	74 17                	je     80214e <ipc_send+0x4a>
  802137:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80213a:	74 12                	je     80214e <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80213c:	50                   	push   %eax
  80213d:	68 2e 2a 80 00       	push   $0x802a2e
  802142:	6a 47                	push   $0x47
  802144:	68 3c 2a 80 00       	push   $0x802a3c
  802149:	e8 07 f5 ff ff       	call   801655 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80214e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802151:	75 07                	jne    80215a <ipc_send+0x56>
			sys_yield();
  802153:	e8 12 e0 ff ff       	call   80016a <sys_yield>
  802158:	eb c6                	jmp    802120 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80215a:	85 c0                	test   %eax,%eax
  80215c:	75 c2                	jne    802120 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80215e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802161:	5b                   	pop    %ebx
  802162:	5e                   	pop    %esi
  802163:	5f                   	pop    %edi
  802164:	5d                   	pop    %ebp
  802165:	c3                   	ret    

00802166 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80216c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802171:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802177:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80217d:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802183:	39 ca                	cmp    %ecx,%edx
  802185:	75 13                	jne    80219a <ipc_find_env+0x34>
			return envs[i].env_id;
  802187:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80218d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802192:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802198:	eb 0f                	jmp    8021a9 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80219a:	83 c0 01             	add    $0x1,%eax
  80219d:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021a2:	75 cd                	jne    802171 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021a9:	5d                   	pop    %ebp
  8021aa:	c3                   	ret    

008021ab <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021ab:	55                   	push   %ebp
  8021ac:	89 e5                	mov    %esp,%ebp
  8021ae:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b1:	89 d0                	mov    %edx,%eax
  8021b3:	c1 e8 16             	shr    $0x16,%eax
  8021b6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021bd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021c2:	f6 c1 01             	test   $0x1,%cl
  8021c5:	74 1d                	je     8021e4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021c7:	c1 ea 0c             	shr    $0xc,%edx
  8021ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021d1:	f6 c2 01             	test   $0x1,%dl
  8021d4:	74 0e                	je     8021e4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021d6:	c1 ea 0c             	shr    $0xc,%edx
  8021d9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021e0:	ef 
  8021e1:	0f b7 c0             	movzwl %ax,%eax
}
  8021e4:	5d                   	pop    %ebp
  8021e5:	c3                   	ret    
  8021e6:	66 90                	xchg   %ax,%ax
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

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
