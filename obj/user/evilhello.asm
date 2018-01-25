
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
  800040:	e8 89 00 00 00       	call   8000ce <sys_cputs>
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
  800055:	e8 f2 00 00 00       	call   80014c <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	89 c2                	mov    %eax,%edx
  800061:	c1 e2 07             	shl    $0x7,%edx
  800064:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x31>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 2a 00 00 00       	call   8000b4 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80009a:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  80009f:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000a1:	e8 a6 00 00 00       	call   80014c <sys_getenvid>
  8000a6:	83 ec 0c             	sub    $0xc,%esp
  8000a9:	50                   	push   %eax
  8000aa:	e8 ec 02 00 00       	call   80039b <sys_thread_free>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ba:	e8 b9 07 00 00       	call   800878 <close_all>
	sys_env_destroy(0);
  8000bf:	83 ec 0c             	sub    $0xc,%esp
  8000c2:	6a 00                	push   $0x0
  8000c4:	e8 42 00 00 00       	call   80010b <sys_env_destroy>
}
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	c9                   	leave  
  8000cd:	c3                   	ret    

008000ce <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	89 c3                	mov    %eax,%ebx
  8000e1:	89 c7                	mov    %eax,%edi
  8000e3:	89 c6                	mov    %eax,%esi
  8000e5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5f                   	pop    %edi
  8000ea:	5d                   	pop    %ebp
  8000eb:	c3                   	ret    

008000ec <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fc:	89 d1                	mov    %edx,%ecx
  8000fe:	89 d3                	mov    %edx,%ebx
  800100:	89 d7                	mov    %edx,%edi
  800102:	89 d6                	mov    %edx,%esi
  800104:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	5f                   	pop    %edi
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	57                   	push   %edi
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
  800111:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800114:	b9 00 00 00 00       	mov    $0x0,%ecx
  800119:	b8 03 00 00 00       	mov    $0x3,%eax
  80011e:	8b 55 08             	mov    0x8(%ebp),%edx
  800121:	89 cb                	mov    %ecx,%ebx
  800123:	89 cf                	mov    %ecx,%edi
  800125:	89 ce                	mov    %ecx,%esi
  800127:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800129:	85 c0                	test   %eax,%eax
  80012b:	7e 17                	jle    800144 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	50                   	push   %eax
  800131:	6a 03                	push   $0x3
  800133:	68 ca 21 80 00       	push   $0x8021ca
  800138:	6a 23                	push   $0x23
  80013a:	68 e7 21 80 00       	push   $0x8021e7
  80013f:	e8 53 12 00 00       	call   801397 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800144:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800147:	5b                   	pop    %ebx
  800148:	5e                   	pop    %esi
  800149:	5f                   	pop    %edi
  80014a:	5d                   	pop    %ebp
  80014b:	c3                   	ret    

0080014c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	57                   	push   %edi
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800152:	ba 00 00 00 00       	mov    $0x0,%edx
  800157:	b8 02 00 00 00       	mov    $0x2,%eax
  80015c:	89 d1                	mov    %edx,%ecx
  80015e:	89 d3                	mov    %edx,%ebx
  800160:	89 d7                	mov    %edx,%edi
  800162:	89 d6                	mov    %edx,%esi
  800164:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800166:	5b                   	pop    %ebx
  800167:	5e                   	pop    %esi
  800168:	5f                   	pop    %edi
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    

0080016b <sys_yield>:

void
sys_yield(void)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	57                   	push   %edi
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	ba 00 00 00 00       	mov    $0x0,%edx
  800176:	b8 0b 00 00 00       	mov    $0xb,%eax
  80017b:	89 d1                	mov    %edx,%ecx
  80017d:	89 d3                	mov    %edx,%ebx
  80017f:	89 d7                	mov    %edx,%edi
  800181:	89 d6                	mov    %edx,%esi
  800183:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    

0080018a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	57                   	push   %edi
  80018e:	56                   	push   %esi
  80018f:	53                   	push   %ebx
  800190:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800193:	be 00 00 00 00       	mov    $0x0,%esi
  800198:	b8 04 00 00 00       	mov    $0x4,%eax
  80019d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a6:	89 f7                	mov    %esi,%edi
  8001a8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001aa:	85 c0                	test   %eax,%eax
  8001ac:	7e 17                	jle    8001c5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ae:	83 ec 0c             	sub    $0xc,%esp
  8001b1:	50                   	push   %eax
  8001b2:	6a 04                	push   $0x4
  8001b4:	68 ca 21 80 00       	push   $0x8021ca
  8001b9:	6a 23                	push   $0x23
  8001bb:	68 e7 21 80 00       	push   $0x8021e7
  8001c0:	e8 d2 11 00 00       	call   801397 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c8:	5b                   	pop    %ebx
  8001c9:	5e                   	pop    %esi
  8001ca:	5f                   	pop    %edi
  8001cb:	5d                   	pop    %ebp
  8001cc:	c3                   	ret    

008001cd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	57                   	push   %edi
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
  8001d3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001de:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ec:	85 c0                	test   %eax,%eax
  8001ee:	7e 17                	jle    800207 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f0:	83 ec 0c             	sub    $0xc,%esp
  8001f3:	50                   	push   %eax
  8001f4:	6a 05                	push   $0x5
  8001f6:	68 ca 21 80 00       	push   $0x8021ca
  8001fb:	6a 23                	push   $0x23
  8001fd:	68 e7 21 80 00       	push   $0x8021e7
  800202:	e8 90 11 00 00       	call   801397 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5f                   	pop    %edi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800218:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021d:	b8 06 00 00 00       	mov    $0x6,%eax
  800222:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800225:	8b 55 08             	mov    0x8(%ebp),%edx
  800228:	89 df                	mov    %ebx,%edi
  80022a:	89 de                	mov    %ebx,%esi
  80022c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80022e:	85 c0                	test   %eax,%eax
  800230:	7e 17                	jle    800249 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	50                   	push   %eax
  800236:	6a 06                	push   $0x6
  800238:	68 ca 21 80 00       	push   $0x8021ca
  80023d:	6a 23                	push   $0x23
  80023f:	68 e7 21 80 00       	push   $0x8021e7
  800244:	e8 4e 11 00 00       	call   801397 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800249:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024c:	5b                   	pop    %ebx
  80024d:	5e                   	pop    %esi
  80024e:	5f                   	pop    %edi
  80024f:	5d                   	pop    %ebp
  800250:	c3                   	ret    

00800251 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	57                   	push   %edi
  800255:	56                   	push   %esi
  800256:	53                   	push   %ebx
  800257:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025f:	b8 08 00 00 00       	mov    $0x8,%eax
  800264:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800267:	8b 55 08             	mov    0x8(%ebp),%edx
  80026a:	89 df                	mov    %ebx,%edi
  80026c:	89 de                	mov    %ebx,%esi
  80026e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800270:	85 c0                	test   %eax,%eax
  800272:	7e 17                	jle    80028b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800274:	83 ec 0c             	sub    $0xc,%esp
  800277:	50                   	push   %eax
  800278:	6a 08                	push   $0x8
  80027a:	68 ca 21 80 00       	push   $0x8021ca
  80027f:	6a 23                	push   $0x23
  800281:	68 e7 21 80 00       	push   $0x8021e7
  800286:	e8 0c 11 00 00       	call   801397 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80028b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028e:	5b                   	pop    %ebx
  80028f:	5e                   	pop    %esi
  800290:	5f                   	pop    %edi
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	57                   	push   %edi
  800297:	56                   	push   %esi
  800298:	53                   	push   %ebx
  800299:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	89 df                	mov    %ebx,%edi
  8002ae:	89 de                	mov    %ebx,%esi
  8002b0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	7e 17                	jle    8002cd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b6:	83 ec 0c             	sub    $0xc,%esp
  8002b9:	50                   	push   %eax
  8002ba:	6a 09                	push   $0x9
  8002bc:	68 ca 21 80 00       	push   $0x8021ca
  8002c1:	6a 23                	push   $0x23
  8002c3:	68 e7 21 80 00       	push   $0x8021e7
  8002c8:	e8 ca 10 00 00       	call   801397 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d0:	5b                   	pop    %ebx
  8002d1:	5e                   	pop    %esi
  8002d2:	5f                   	pop    %edi
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	57                   	push   %edi
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ee:	89 df                	mov    %ebx,%edi
  8002f0:	89 de                	mov    %ebx,%esi
  8002f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7e 17                	jle    80030f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	6a 0a                	push   $0xa
  8002fe:	68 ca 21 80 00       	push   $0x8021ca
  800303:	6a 23                	push   $0x23
  800305:	68 e7 21 80 00       	push   $0x8021e7
  80030a:	e8 88 10 00 00       	call   801397 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80030f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5f                   	pop    %edi
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	57                   	push   %edi
  80031b:	56                   	push   %esi
  80031c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031d:	be 00 00 00 00       	mov    $0x0,%esi
  800322:	b8 0c 00 00 00       	mov    $0xc,%eax
  800327:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032a:	8b 55 08             	mov    0x8(%ebp),%edx
  80032d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800330:	8b 7d 14             	mov    0x14(%ebp),%edi
  800333:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800335:	5b                   	pop    %ebx
  800336:	5e                   	pop    %esi
  800337:	5f                   	pop    %edi
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	57                   	push   %edi
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
  800340:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800343:	b9 00 00 00 00       	mov    $0x0,%ecx
  800348:	b8 0d 00 00 00       	mov    $0xd,%eax
  80034d:	8b 55 08             	mov    0x8(%ebp),%edx
  800350:	89 cb                	mov    %ecx,%ebx
  800352:	89 cf                	mov    %ecx,%edi
  800354:	89 ce                	mov    %ecx,%esi
  800356:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800358:	85 c0                	test   %eax,%eax
  80035a:	7e 17                	jle    800373 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035c:	83 ec 0c             	sub    $0xc,%esp
  80035f:	50                   	push   %eax
  800360:	6a 0d                	push   $0xd
  800362:	68 ca 21 80 00       	push   $0x8021ca
  800367:	6a 23                	push   $0x23
  800369:	68 e7 21 80 00       	push   $0x8021e7
  80036e:	e8 24 10 00 00       	call   801397 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800373:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800376:	5b                   	pop    %ebx
  800377:	5e                   	pop    %esi
  800378:	5f                   	pop    %edi
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	57                   	push   %edi
  80037f:	56                   	push   %esi
  800380:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800381:	b9 00 00 00 00       	mov    $0x0,%ecx
  800386:	b8 0e 00 00 00       	mov    $0xe,%eax
  80038b:	8b 55 08             	mov    0x8(%ebp),%edx
  80038e:	89 cb                	mov    %ecx,%ebx
  800390:	89 cf                	mov    %ecx,%edi
  800392:	89 ce                	mov    %ecx,%esi
  800394:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800396:	5b                   	pop    %ebx
  800397:	5e                   	pop    %esi
  800398:	5f                   	pop    %edi
  800399:	5d                   	pop    %ebp
  80039a:	c3                   	ret    

0080039b <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	57                   	push   %edi
  80039f:	56                   	push   %esi
  8003a0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a6:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ae:	89 cb                	mov    %ecx,%ebx
  8003b0:	89 cf                	mov    %ecx,%edi
  8003b2:	89 ce                	mov    %ecx,%esi
  8003b4:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003b6:	5b                   	pop    %ebx
  8003b7:	5e                   	pop    %esi
  8003b8:	5f                   	pop    %edi
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 04             	sub    $0x4,%esp
  8003c2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003c5:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003c7:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003cb:	74 11                	je     8003de <pgfault+0x23>
  8003cd:	89 d8                	mov    %ebx,%eax
  8003cf:	c1 e8 0c             	shr    $0xc,%eax
  8003d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003d9:	f6 c4 08             	test   $0x8,%ah
  8003dc:	75 14                	jne    8003f2 <pgfault+0x37>
		panic("faulting access");
  8003de:	83 ec 04             	sub    $0x4,%esp
  8003e1:	68 f5 21 80 00       	push   $0x8021f5
  8003e6:	6a 1e                	push   $0x1e
  8003e8:	68 05 22 80 00       	push   $0x802205
  8003ed:	e8 a5 0f 00 00       	call   801397 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8003f2:	83 ec 04             	sub    $0x4,%esp
  8003f5:	6a 07                	push   $0x7
  8003f7:	68 00 f0 7f 00       	push   $0x7ff000
  8003fc:	6a 00                	push   $0x0
  8003fe:	e8 87 fd ff ff       	call   80018a <sys_page_alloc>
	if (r < 0) {
  800403:	83 c4 10             	add    $0x10,%esp
  800406:	85 c0                	test   %eax,%eax
  800408:	79 12                	jns    80041c <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  80040a:	50                   	push   %eax
  80040b:	68 10 22 80 00       	push   $0x802210
  800410:	6a 2c                	push   $0x2c
  800412:	68 05 22 80 00       	push   $0x802205
  800417:	e8 7b 0f 00 00       	call   801397 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80041c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800422:	83 ec 04             	sub    $0x4,%esp
  800425:	68 00 10 00 00       	push   $0x1000
  80042a:	53                   	push   %ebx
  80042b:	68 00 f0 7f 00       	push   $0x7ff000
  800430:	e8 ba 17 00 00       	call   801bef <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800435:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80043c:	53                   	push   %ebx
  80043d:	6a 00                	push   $0x0
  80043f:	68 00 f0 7f 00       	push   $0x7ff000
  800444:	6a 00                	push   $0x0
  800446:	e8 82 fd ff ff       	call   8001cd <sys_page_map>
	if (r < 0) {
  80044b:	83 c4 20             	add    $0x20,%esp
  80044e:	85 c0                	test   %eax,%eax
  800450:	79 12                	jns    800464 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800452:	50                   	push   %eax
  800453:	68 10 22 80 00       	push   $0x802210
  800458:	6a 33                	push   $0x33
  80045a:	68 05 22 80 00       	push   $0x802205
  80045f:	e8 33 0f 00 00       	call   801397 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	68 00 f0 7f 00       	push   $0x7ff000
  80046c:	6a 00                	push   $0x0
  80046e:	e8 9c fd ff ff       	call   80020f <sys_page_unmap>
	if (r < 0) {
  800473:	83 c4 10             	add    $0x10,%esp
  800476:	85 c0                	test   %eax,%eax
  800478:	79 12                	jns    80048c <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80047a:	50                   	push   %eax
  80047b:	68 10 22 80 00       	push   $0x802210
  800480:	6a 37                	push   $0x37
  800482:	68 05 22 80 00       	push   $0x802205
  800487:	e8 0b 0f 00 00       	call   801397 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80048c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	57                   	push   %edi
  800495:	56                   	push   %esi
  800496:	53                   	push   %ebx
  800497:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80049a:	68 bb 03 80 00       	push   $0x8003bb
  80049f:	e8 98 18 00 00       	call   801d3c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004a4:	b8 07 00 00 00       	mov    $0x7,%eax
  8004a9:	cd 30                	int    $0x30
  8004ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	79 17                	jns    8004cc <fork+0x3b>
		panic("fork fault %e");
  8004b5:	83 ec 04             	sub    $0x4,%esp
  8004b8:	68 29 22 80 00       	push   $0x802229
  8004bd:	68 84 00 00 00       	push   $0x84
  8004c2:	68 05 22 80 00       	push   $0x802205
  8004c7:	e8 cb 0e 00 00       	call   801397 <_panic>
  8004cc:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d2:	75 25                	jne    8004f9 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004d4:	e8 73 fc ff ff       	call   80014c <sys_getenvid>
  8004d9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004de:	89 c2                	mov    %eax,%edx
  8004e0:	c1 e2 07             	shl    $0x7,%edx
  8004e3:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8004ea:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f4:	e9 61 01 00 00       	jmp    80065a <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8004f9:	83 ec 04             	sub    $0x4,%esp
  8004fc:	6a 07                	push   $0x7
  8004fe:	68 00 f0 bf ee       	push   $0xeebff000
  800503:	ff 75 e4             	pushl  -0x1c(%ebp)
  800506:	e8 7f fc ff ff       	call   80018a <sys_page_alloc>
  80050b:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80050e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800513:	89 d8                	mov    %ebx,%eax
  800515:	c1 e8 16             	shr    $0x16,%eax
  800518:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80051f:	a8 01                	test   $0x1,%al
  800521:	0f 84 fc 00 00 00    	je     800623 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800527:	89 d8                	mov    %ebx,%eax
  800529:	c1 e8 0c             	shr    $0xc,%eax
  80052c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800533:	f6 c2 01             	test   $0x1,%dl
  800536:	0f 84 e7 00 00 00    	je     800623 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80053c:	89 c6                	mov    %eax,%esi
  80053e:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800541:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800548:	f6 c6 04             	test   $0x4,%dh
  80054b:	74 39                	je     800586 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80054d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800554:	83 ec 0c             	sub    $0xc,%esp
  800557:	25 07 0e 00 00       	and    $0xe07,%eax
  80055c:	50                   	push   %eax
  80055d:	56                   	push   %esi
  80055e:	57                   	push   %edi
  80055f:	56                   	push   %esi
  800560:	6a 00                	push   $0x0
  800562:	e8 66 fc ff ff       	call   8001cd <sys_page_map>
		if (r < 0) {
  800567:	83 c4 20             	add    $0x20,%esp
  80056a:	85 c0                	test   %eax,%eax
  80056c:	0f 89 b1 00 00 00    	jns    800623 <fork+0x192>
		    	panic("sys page map fault %e");
  800572:	83 ec 04             	sub    $0x4,%esp
  800575:	68 37 22 80 00       	push   $0x802237
  80057a:	6a 54                	push   $0x54
  80057c:	68 05 22 80 00       	push   $0x802205
  800581:	e8 11 0e 00 00       	call   801397 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800586:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80058d:	f6 c2 02             	test   $0x2,%dl
  800590:	75 0c                	jne    80059e <fork+0x10d>
  800592:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800599:	f6 c4 08             	test   $0x8,%ah
  80059c:	74 5b                	je     8005f9 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80059e:	83 ec 0c             	sub    $0xc,%esp
  8005a1:	68 05 08 00 00       	push   $0x805
  8005a6:	56                   	push   %esi
  8005a7:	57                   	push   %edi
  8005a8:	56                   	push   %esi
  8005a9:	6a 00                	push   $0x0
  8005ab:	e8 1d fc ff ff       	call   8001cd <sys_page_map>
		if (r < 0) {
  8005b0:	83 c4 20             	add    $0x20,%esp
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	79 14                	jns    8005cb <fork+0x13a>
		    	panic("sys page map fault %e");
  8005b7:	83 ec 04             	sub    $0x4,%esp
  8005ba:	68 37 22 80 00       	push   $0x802237
  8005bf:	6a 5b                	push   $0x5b
  8005c1:	68 05 22 80 00       	push   $0x802205
  8005c6:	e8 cc 0d 00 00       	call   801397 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005cb:	83 ec 0c             	sub    $0xc,%esp
  8005ce:	68 05 08 00 00       	push   $0x805
  8005d3:	56                   	push   %esi
  8005d4:	6a 00                	push   $0x0
  8005d6:	56                   	push   %esi
  8005d7:	6a 00                	push   $0x0
  8005d9:	e8 ef fb ff ff       	call   8001cd <sys_page_map>
		if (r < 0) {
  8005de:	83 c4 20             	add    $0x20,%esp
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	79 3e                	jns    800623 <fork+0x192>
		    	panic("sys page map fault %e");
  8005e5:	83 ec 04             	sub    $0x4,%esp
  8005e8:	68 37 22 80 00       	push   $0x802237
  8005ed:	6a 5f                	push   $0x5f
  8005ef:	68 05 22 80 00       	push   $0x802205
  8005f4:	e8 9e 0d 00 00       	call   801397 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8005f9:	83 ec 0c             	sub    $0xc,%esp
  8005fc:	6a 05                	push   $0x5
  8005fe:	56                   	push   %esi
  8005ff:	57                   	push   %edi
  800600:	56                   	push   %esi
  800601:	6a 00                	push   $0x0
  800603:	e8 c5 fb ff ff       	call   8001cd <sys_page_map>
		if (r < 0) {
  800608:	83 c4 20             	add    $0x20,%esp
  80060b:	85 c0                	test   %eax,%eax
  80060d:	79 14                	jns    800623 <fork+0x192>
		    	panic("sys page map fault %e");
  80060f:	83 ec 04             	sub    $0x4,%esp
  800612:	68 37 22 80 00       	push   $0x802237
  800617:	6a 64                	push   $0x64
  800619:	68 05 22 80 00       	push   $0x802205
  80061e:	e8 74 0d 00 00       	call   801397 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800623:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800629:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80062f:	0f 85 de fe ff ff    	jne    800513 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800635:	a1 04 40 80 00       	mov    0x804004,%eax
  80063a:	8b 40 70             	mov    0x70(%eax),%eax
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	50                   	push   %eax
  800641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800644:	57                   	push   %edi
  800645:	e8 8b fc ff ff       	call   8002d5 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80064a:	83 c4 08             	add    $0x8,%esp
  80064d:	6a 02                	push   $0x2
  80064f:	57                   	push   %edi
  800650:	e8 fc fb ff ff       	call   800251 <sys_env_set_status>
	
	return envid;
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80065a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065d:	5b                   	pop    %ebx
  80065e:	5e                   	pop    %esi
  80065f:	5f                   	pop    %edi
  800660:	5d                   	pop    %ebp
  800661:	c3                   	ret    

00800662 <sfork>:

envid_t
sfork(void)
{
  800662:	55                   	push   %ebp
  800663:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800665:	b8 00 00 00 00       	mov    $0x0,%eax
  80066a:	5d                   	pop    %ebp
  80066b:	c3                   	ret    

0080066c <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	56                   	push   %esi
  800670:	53                   	push   %ebx
  800671:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800674:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	53                   	push   %ebx
  80067e:	68 50 22 80 00       	push   $0x802250
  800683:	e8 e8 0d 00 00       	call   801470 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800688:	c7 04 24 94 00 80 00 	movl   $0x800094,(%esp)
  80068f:	e8 e7 fc ff ff       	call   80037b <sys_thread_create>
  800694:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  800696:	83 c4 08             	add    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	68 50 22 80 00       	push   $0x802250
  80069f:	e8 cc 0d 00 00       	call   801470 <cprintf>
	return id;
	//return 0;
}
  8006a4:	89 f0                	mov    %esi,%eax
  8006a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006a9:	5b                   	pop    %ebx
  8006aa:	5e                   	pop    %esi
  8006ab:	5d                   	pop    %ebp
  8006ac:	c3                   	ret    

008006ad <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	05 00 00 00 30       	add    $0x30000000,%eax
  8006b8:	c1 e8 0c             	shr    $0xc,%eax
}
  8006bb:	5d                   	pop    %ebp
  8006bc:	c3                   	ret    

008006bd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c3:	05 00 00 00 30       	add    $0x30000000,%eax
  8006c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006cd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006d2:	5d                   	pop    %ebp
  8006d3:	c3                   	ret    

008006d4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006da:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006df:	89 c2                	mov    %eax,%edx
  8006e1:	c1 ea 16             	shr    $0x16,%edx
  8006e4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8006eb:	f6 c2 01             	test   $0x1,%dl
  8006ee:	74 11                	je     800701 <fd_alloc+0x2d>
  8006f0:	89 c2                	mov    %eax,%edx
  8006f2:	c1 ea 0c             	shr    $0xc,%edx
  8006f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006fc:	f6 c2 01             	test   $0x1,%dl
  8006ff:	75 09                	jne    80070a <fd_alloc+0x36>
			*fd_store = fd;
  800701:	89 01                	mov    %eax,(%ecx)
			return 0;
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
  800708:	eb 17                	jmp    800721 <fd_alloc+0x4d>
  80070a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80070f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800714:	75 c9                	jne    8006df <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800716:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80071c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800721:	5d                   	pop    %ebp
  800722:	c3                   	ret    

00800723 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800729:	83 f8 1f             	cmp    $0x1f,%eax
  80072c:	77 36                	ja     800764 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80072e:	c1 e0 0c             	shl    $0xc,%eax
  800731:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800736:	89 c2                	mov    %eax,%edx
  800738:	c1 ea 16             	shr    $0x16,%edx
  80073b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800742:	f6 c2 01             	test   $0x1,%dl
  800745:	74 24                	je     80076b <fd_lookup+0x48>
  800747:	89 c2                	mov    %eax,%edx
  800749:	c1 ea 0c             	shr    $0xc,%edx
  80074c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800753:	f6 c2 01             	test   $0x1,%dl
  800756:	74 1a                	je     800772 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800758:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075b:	89 02                	mov    %eax,(%edx)
	return 0;
  80075d:	b8 00 00 00 00       	mov    $0x0,%eax
  800762:	eb 13                	jmp    800777 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800764:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800769:	eb 0c                	jmp    800777 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80076b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800770:	eb 05                	jmp    800777 <fd_lookup+0x54>
  800772:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800782:	ba f0 22 80 00       	mov    $0x8022f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800787:	eb 13                	jmp    80079c <dev_lookup+0x23>
  800789:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80078c:	39 08                	cmp    %ecx,(%eax)
  80078e:	75 0c                	jne    80079c <dev_lookup+0x23>
			*dev = devtab[i];
  800790:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800793:	89 01                	mov    %eax,(%ecx)
			return 0;
  800795:	b8 00 00 00 00       	mov    $0x0,%eax
  80079a:	eb 2e                	jmp    8007ca <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80079c:	8b 02                	mov    (%edx),%eax
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	75 e7                	jne    800789 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007a2:	a1 04 40 80 00       	mov    0x804004,%eax
  8007a7:	8b 40 54             	mov    0x54(%eax),%eax
  8007aa:	83 ec 04             	sub    $0x4,%esp
  8007ad:	51                   	push   %ecx
  8007ae:	50                   	push   %eax
  8007af:	68 74 22 80 00       	push   $0x802274
  8007b4:	e8 b7 0c 00 00       	call   801470 <cprintf>
	*dev = 0;
  8007b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007c2:	83 c4 10             	add    $0x10,%esp
  8007c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    

008007cc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	56                   	push   %esi
  8007d0:	53                   	push   %ebx
  8007d1:	83 ec 10             	sub    $0x10,%esp
  8007d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8007e4:	c1 e8 0c             	shr    $0xc,%eax
  8007e7:	50                   	push   %eax
  8007e8:	e8 36 ff ff ff       	call   800723 <fd_lookup>
  8007ed:	83 c4 08             	add    $0x8,%esp
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	78 05                	js     8007f9 <fd_close+0x2d>
	    || fd != fd2)
  8007f4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8007f7:	74 0c                	je     800805 <fd_close+0x39>
		return (must_exist ? r : 0);
  8007f9:	84 db                	test   %bl,%bl
  8007fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800800:	0f 44 c2             	cmove  %edx,%eax
  800803:	eb 41                	jmp    800846 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800805:	83 ec 08             	sub    $0x8,%esp
  800808:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080b:	50                   	push   %eax
  80080c:	ff 36                	pushl  (%esi)
  80080e:	e8 66 ff ff ff       	call   800779 <dev_lookup>
  800813:	89 c3                	mov    %eax,%ebx
  800815:	83 c4 10             	add    $0x10,%esp
  800818:	85 c0                	test   %eax,%eax
  80081a:	78 1a                	js     800836 <fd_close+0x6a>
		if (dev->dev_close)
  80081c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800822:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800827:	85 c0                	test   %eax,%eax
  800829:	74 0b                	je     800836 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80082b:	83 ec 0c             	sub    $0xc,%esp
  80082e:	56                   	push   %esi
  80082f:	ff d0                	call   *%eax
  800831:	89 c3                	mov    %eax,%ebx
  800833:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800836:	83 ec 08             	sub    $0x8,%esp
  800839:	56                   	push   %esi
  80083a:	6a 00                	push   $0x0
  80083c:	e8 ce f9 ff ff       	call   80020f <sys_page_unmap>
	return r;
  800841:	83 c4 10             	add    $0x10,%esp
  800844:	89 d8                	mov    %ebx,%eax
}
  800846:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800849:	5b                   	pop    %ebx
  80084a:	5e                   	pop    %esi
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800853:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800856:	50                   	push   %eax
  800857:	ff 75 08             	pushl  0x8(%ebp)
  80085a:	e8 c4 fe ff ff       	call   800723 <fd_lookup>
  80085f:	83 c4 08             	add    $0x8,%esp
  800862:	85 c0                	test   %eax,%eax
  800864:	78 10                	js     800876 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800866:	83 ec 08             	sub    $0x8,%esp
  800869:	6a 01                	push   $0x1
  80086b:	ff 75 f4             	pushl  -0xc(%ebp)
  80086e:	e8 59 ff ff ff       	call   8007cc <fd_close>
  800873:	83 c4 10             	add    $0x10,%esp
}
  800876:	c9                   	leave  
  800877:	c3                   	ret    

00800878 <close_all>:

void
close_all(void)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	53                   	push   %ebx
  80087c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80087f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800884:	83 ec 0c             	sub    $0xc,%esp
  800887:	53                   	push   %ebx
  800888:	e8 c0 ff ff ff       	call   80084d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80088d:	83 c3 01             	add    $0x1,%ebx
  800890:	83 c4 10             	add    $0x10,%esp
  800893:	83 fb 20             	cmp    $0x20,%ebx
  800896:	75 ec                	jne    800884 <close_all+0xc>
		close(i);
}
  800898:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    

0080089d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	57                   	push   %edi
  8008a1:	56                   	push   %esi
  8008a2:	53                   	push   %ebx
  8008a3:	83 ec 2c             	sub    $0x2c,%esp
  8008a6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008ac:	50                   	push   %eax
  8008ad:	ff 75 08             	pushl  0x8(%ebp)
  8008b0:	e8 6e fe ff ff       	call   800723 <fd_lookup>
  8008b5:	83 c4 08             	add    $0x8,%esp
  8008b8:	85 c0                	test   %eax,%eax
  8008ba:	0f 88 c1 00 00 00    	js     800981 <dup+0xe4>
		return r;
	close(newfdnum);
  8008c0:	83 ec 0c             	sub    $0xc,%esp
  8008c3:	56                   	push   %esi
  8008c4:	e8 84 ff ff ff       	call   80084d <close>

	newfd = INDEX2FD(newfdnum);
  8008c9:	89 f3                	mov    %esi,%ebx
  8008cb:	c1 e3 0c             	shl    $0xc,%ebx
  8008ce:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008d4:	83 c4 04             	add    $0x4,%esp
  8008d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008da:	e8 de fd ff ff       	call   8006bd <fd2data>
  8008df:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008e1:	89 1c 24             	mov    %ebx,(%esp)
  8008e4:	e8 d4 fd ff ff       	call   8006bd <fd2data>
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8008ef:	89 f8                	mov    %edi,%eax
  8008f1:	c1 e8 16             	shr    $0x16,%eax
  8008f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8008fb:	a8 01                	test   $0x1,%al
  8008fd:	74 37                	je     800936 <dup+0x99>
  8008ff:	89 f8                	mov    %edi,%eax
  800901:	c1 e8 0c             	shr    $0xc,%eax
  800904:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80090b:	f6 c2 01             	test   $0x1,%dl
  80090e:	74 26                	je     800936 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800910:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800917:	83 ec 0c             	sub    $0xc,%esp
  80091a:	25 07 0e 00 00       	and    $0xe07,%eax
  80091f:	50                   	push   %eax
  800920:	ff 75 d4             	pushl  -0x2c(%ebp)
  800923:	6a 00                	push   $0x0
  800925:	57                   	push   %edi
  800926:	6a 00                	push   $0x0
  800928:	e8 a0 f8 ff ff       	call   8001cd <sys_page_map>
  80092d:	89 c7                	mov    %eax,%edi
  80092f:	83 c4 20             	add    $0x20,%esp
  800932:	85 c0                	test   %eax,%eax
  800934:	78 2e                	js     800964 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800936:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800939:	89 d0                	mov    %edx,%eax
  80093b:	c1 e8 0c             	shr    $0xc,%eax
  80093e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800945:	83 ec 0c             	sub    $0xc,%esp
  800948:	25 07 0e 00 00       	and    $0xe07,%eax
  80094d:	50                   	push   %eax
  80094e:	53                   	push   %ebx
  80094f:	6a 00                	push   $0x0
  800951:	52                   	push   %edx
  800952:	6a 00                	push   $0x0
  800954:	e8 74 f8 ff ff       	call   8001cd <sys_page_map>
  800959:	89 c7                	mov    %eax,%edi
  80095b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80095e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800960:	85 ff                	test   %edi,%edi
  800962:	79 1d                	jns    800981 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800964:	83 ec 08             	sub    $0x8,%esp
  800967:	53                   	push   %ebx
  800968:	6a 00                	push   $0x0
  80096a:	e8 a0 f8 ff ff       	call   80020f <sys_page_unmap>
	sys_page_unmap(0, nva);
  80096f:	83 c4 08             	add    $0x8,%esp
  800972:	ff 75 d4             	pushl  -0x2c(%ebp)
  800975:	6a 00                	push   $0x0
  800977:	e8 93 f8 ff ff       	call   80020f <sys_page_unmap>
	return r;
  80097c:	83 c4 10             	add    $0x10,%esp
  80097f:	89 f8                	mov    %edi,%eax
}
  800981:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800984:	5b                   	pop    %ebx
  800985:	5e                   	pop    %esi
  800986:	5f                   	pop    %edi
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	53                   	push   %ebx
  80098d:	83 ec 14             	sub    $0x14,%esp
  800990:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800993:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800996:	50                   	push   %eax
  800997:	53                   	push   %ebx
  800998:	e8 86 fd ff ff       	call   800723 <fd_lookup>
  80099d:	83 c4 08             	add    $0x8,%esp
  8009a0:	89 c2                	mov    %eax,%edx
  8009a2:	85 c0                	test   %eax,%eax
  8009a4:	78 6d                	js     800a13 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009a6:	83 ec 08             	sub    $0x8,%esp
  8009a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009ac:	50                   	push   %eax
  8009ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b0:	ff 30                	pushl  (%eax)
  8009b2:	e8 c2 fd ff ff       	call   800779 <dev_lookup>
  8009b7:	83 c4 10             	add    $0x10,%esp
  8009ba:	85 c0                	test   %eax,%eax
  8009bc:	78 4c                	js     800a0a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009be:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009c1:	8b 42 08             	mov    0x8(%edx),%eax
  8009c4:	83 e0 03             	and    $0x3,%eax
  8009c7:	83 f8 01             	cmp    $0x1,%eax
  8009ca:	75 21                	jne    8009ed <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8009d1:	8b 40 54             	mov    0x54(%eax),%eax
  8009d4:	83 ec 04             	sub    $0x4,%esp
  8009d7:	53                   	push   %ebx
  8009d8:	50                   	push   %eax
  8009d9:	68 b5 22 80 00       	push   $0x8022b5
  8009de:	e8 8d 0a 00 00       	call   801470 <cprintf>
		return -E_INVAL;
  8009e3:	83 c4 10             	add    $0x10,%esp
  8009e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8009eb:	eb 26                	jmp    800a13 <read+0x8a>
	}
	if (!dev->dev_read)
  8009ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f0:	8b 40 08             	mov    0x8(%eax),%eax
  8009f3:	85 c0                	test   %eax,%eax
  8009f5:	74 17                	je     800a0e <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8009f7:	83 ec 04             	sub    $0x4,%esp
  8009fa:	ff 75 10             	pushl  0x10(%ebp)
  8009fd:	ff 75 0c             	pushl  0xc(%ebp)
  800a00:	52                   	push   %edx
  800a01:	ff d0                	call   *%eax
  800a03:	89 c2                	mov    %eax,%edx
  800a05:	83 c4 10             	add    $0x10,%esp
  800a08:	eb 09                	jmp    800a13 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a0a:	89 c2                	mov    %eax,%edx
  800a0c:	eb 05                	jmp    800a13 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a0e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a13:	89 d0                	mov    %edx,%eax
  800a15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a18:	c9                   	leave  
  800a19:	c3                   	ret    

00800a1a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	57                   	push   %edi
  800a1e:	56                   	push   %esi
  800a1f:	53                   	push   %ebx
  800a20:	83 ec 0c             	sub    $0xc,%esp
  800a23:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a26:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a2e:	eb 21                	jmp    800a51 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a30:	83 ec 04             	sub    $0x4,%esp
  800a33:	89 f0                	mov    %esi,%eax
  800a35:	29 d8                	sub    %ebx,%eax
  800a37:	50                   	push   %eax
  800a38:	89 d8                	mov    %ebx,%eax
  800a3a:	03 45 0c             	add    0xc(%ebp),%eax
  800a3d:	50                   	push   %eax
  800a3e:	57                   	push   %edi
  800a3f:	e8 45 ff ff ff       	call   800989 <read>
		if (m < 0)
  800a44:	83 c4 10             	add    $0x10,%esp
  800a47:	85 c0                	test   %eax,%eax
  800a49:	78 10                	js     800a5b <readn+0x41>
			return m;
		if (m == 0)
  800a4b:	85 c0                	test   %eax,%eax
  800a4d:	74 0a                	je     800a59 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a4f:	01 c3                	add    %eax,%ebx
  800a51:	39 f3                	cmp    %esi,%ebx
  800a53:	72 db                	jb     800a30 <readn+0x16>
  800a55:	89 d8                	mov    %ebx,%eax
  800a57:	eb 02                	jmp    800a5b <readn+0x41>
  800a59:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5f                   	pop    %edi
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	53                   	push   %ebx
  800a67:	83 ec 14             	sub    $0x14,%esp
  800a6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a70:	50                   	push   %eax
  800a71:	53                   	push   %ebx
  800a72:	e8 ac fc ff ff       	call   800723 <fd_lookup>
  800a77:	83 c4 08             	add    $0x8,%esp
  800a7a:	89 c2                	mov    %eax,%edx
  800a7c:	85 c0                	test   %eax,%eax
  800a7e:	78 68                	js     800ae8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a80:	83 ec 08             	sub    $0x8,%esp
  800a83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a86:	50                   	push   %eax
  800a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a8a:	ff 30                	pushl  (%eax)
  800a8c:	e8 e8 fc ff ff       	call   800779 <dev_lookup>
  800a91:	83 c4 10             	add    $0x10,%esp
  800a94:	85 c0                	test   %eax,%eax
  800a96:	78 47                	js     800adf <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a9b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a9f:	75 21                	jne    800ac2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800aa1:	a1 04 40 80 00       	mov    0x804004,%eax
  800aa6:	8b 40 54             	mov    0x54(%eax),%eax
  800aa9:	83 ec 04             	sub    $0x4,%esp
  800aac:	53                   	push   %ebx
  800aad:	50                   	push   %eax
  800aae:	68 d1 22 80 00       	push   $0x8022d1
  800ab3:	e8 b8 09 00 00       	call   801470 <cprintf>
		return -E_INVAL;
  800ab8:	83 c4 10             	add    $0x10,%esp
  800abb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ac0:	eb 26                	jmp    800ae8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ac2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac5:	8b 52 0c             	mov    0xc(%edx),%edx
  800ac8:	85 d2                	test   %edx,%edx
  800aca:	74 17                	je     800ae3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800acc:	83 ec 04             	sub    $0x4,%esp
  800acf:	ff 75 10             	pushl  0x10(%ebp)
  800ad2:	ff 75 0c             	pushl  0xc(%ebp)
  800ad5:	50                   	push   %eax
  800ad6:	ff d2                	call   *%edx
  800ad8:	89 c2                	mov    %eax,%edx
  800ada:	83 c4 10             	add    $0x10,%esp
  800add:	eb 09                	jmp    800ae8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800adf:	89 c2                	mov    %eax,%edx
  800ae1:	eb 05                	jmp    800ae8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ae3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800ae8:	89 d0                	mov    %edx,%eax
  800aea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aed:	c9                   	leave  
  800aee:	c3                   	ret    

00800aef <seek>:

int
seek(int fdnum, off_t offset)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800af5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800af8:	50                   	push   %eax
  800af9:	ff 75 08             	pushl  0x8(%ebp)
  800afc:	e8 22 fc ff ff       	call   800723 <fd_lookup>
  800b01:	83 c4 08             	add    $0x8,%esp
  800b04:	85 c0                	test   %eax,%eax
  800b06:	78 0e                	js     800b16 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b08:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b16:	c9                   	leave  
  800b17:	c3                   	ret    

00800b18 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	53                   	push   %ebx
  800b1c:	83 ec 14             	sub    $0x14,%esp
  800b1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b22:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b25:	50                   	push   %eax
  800b26:	53                   	push   %ebx
  800b27:	e8 f7 fb ff ff       	call   800723 <fd_lookup>
  800b2c:	83 c4 08             	add    $0x8,%esp
  800b2f:	89 c2                	mov    %eax,%edx
  800b31:	85 c0                	test   %eax,%eax
  800b33:	78 65                	js     800b9a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b35:	83 ec 08             	sub    $0x8,%esp
  800b38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b3b:	50                   	push   %eax
  800b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b3f:	ff 30                	pushl  (%eax)
  800b41:	e8 33 fc ff ff       	call   800779 <dev_lookup>
  800b46:	83 c4 10             	add    $0x10,%esp
  800b49:	85 c0                	test   %eax,%eax
  800b4b:	78 44                	js     800b91 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b50:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b54:	75 21                	jne    800b77 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b56:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b5b:	8b 40 54             	mov    0x54(%eax),%eax
  800b5e:	83 ec 04             	sub    $0x4,%esp
  800b61:	53                   	push   %ebx
  800b62:	50                   	push   %eax
  800b63:	68 94 22 80 00       	push   $0x802294
  800b68:	e8 03 09 00 00       	call   801470 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b6d:	83 c4 10             	add    $0x10,%esp
  800b70:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b75:	eb 23                	jmp    800b9a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b77:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b7a:	8b 52 18             	mov    0x18(%edx),%edx
  800b7d:	85 d2                	test   %edx,%edx
  800b7f:	74 14                	je     800b95 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b81:	83 ec 08             	sub    $0x8,%esp
  800b84:	ff 75 0c             	pushl  0xc(%ebp)
  800b87:	50                   	push   %eax
  800b88:	ff d2                	call   *%edx
  800b8a:	89 c2                	mov    %eax,%edx
  800b8c:	83 c4 10             	add    $0x10,%esp
  800b8f:	eb 09                	jmp    800b9a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b91:	89 c2                	mov    %eax,%edx
  800b93:	eb 05                	jmp    800b9a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800b95:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800b9a:	89 d0                	mov    %edx,%eax
  800b9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9f:	c9                   	leave  
  800ba0:	c3                   	ret    

00800ba1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 14             	sub    $0x14,%esp
  800ba8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bae:	50                   	push   %eax
  800baf:	ff 75 08             	pushl  0x8(%ebp)
  800bb2:	e8 6c fb ff ff       	call   800723 <fd_lookup>
  800bb7:	83 c4 08             	add    $0x8,%esp
  800bba:	89 c2                	mov    %eax,%edx
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	78 58                	js     800c18 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bc0:	83 ec 08             	sub    $0x8,%esp
  800bc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bc6:	50                   	push   %eax
  800bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bca:	ff 30                	pushl  (%eax)
  800bcc:	e8 a8 fb ff ff       	call   800779 <dev_lookup>
  800bd1:	83 c4 10             	add    $0x10,%esp
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	78 37                	js     800c0f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bdb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800bdf:	74 32                	je     800c13 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800be1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800be4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800beb:	00 00 00 
	stat->st_isdir = 0;
  800bee:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bf5:	00 00 00 
	stat->st_dev = dev;
  800bf8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800bfe:	83 ec 08             	sub    $0x8,%esp
  800c01:	53                   	push   %ebx
  800c02:	ff 75 f0             	pushl  -0x10(%ebp)
  800c05:	ff 50 14             	call   *0x14(%eax)
  800c08:	89 c2                	mov    %eax,%edx
  800c0a:	83 c4 10             	add    $0x10,%esp
  800c0d:	eb 09                	jmp    800c18 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c0f:	89 c2                	mov    %eax,%edx
  800c11:	eb 05                	jmp    800c18 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c13:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c18:	89 d0                	mov    %edx,%eax
  800c1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c24:	83 ec 08             	sub    $0x8,%esp
  800c27:	6a 00                	push   $0x0
  800c29:	ff 75 08             	pushl  0x8(%ebp)
  800c2c:	e8 e3 01 00 00       	call   800e14 <open>
  800c31:	89 c3                	mov    %eax,%ebx
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	85 c0                	test   %eax,%eax
  800c38:	78 1b                	js     800c55 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c3a:	83 ec 08             	sub    $0x8,%esp
  800c3d:	ff 75 0c             	pushl  0xc(%ebp)
  800c40:	50                   	push   %eax
  800c41:	e8 5b ff ff ff       	call   800ba1 <fstat>
  800c46:	89 c6                	mov    %eax,%esi
	close(fd);
  800c48:	89 1c 24             	mov    %ebx,(%esp)
  800c4b:	e8 fd fb ff ff       	call   80084d <close>
	return r;
  800c50:	83 c4 10             	add    $0x10,%esp
  800c53:	89 f0                	mov    %esi,%eax
}
  800c55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	89 c6                	mov    %eax,%esi
  800c63:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c65:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c6c:	75 12                	jne    800c80 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c6e:	83 ec 0c             	sub    $0xc,%esp
  800c71:	6a 01                	push   $0x1
  800c73:	e8 2d 12 00 00       	call   801ea5 <ipc_find_env>
  800c78:	a3 00 40 80 00       	mov    %eax,0x804000
  800c7d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c80:	6a 07                	push   $0x7
  800c82:	68 00 50 80 00       	push   $0x805000
  800c87:	56                   	push   %esi
  800c88:	ff 35 00 40 80 00    	pushl  0x804000
  800c8e:	e8 b0 11 00 00       	call   801e43 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c93:	83 c4 0c             	add    $0xc,%esp
  800c96:	6a 00                	push   $0x0
  800c98:	53                   	push   %ebx
  800c99:	6a 00                	push   $0x0
  800c9b:	e8 2b 11 00 00       	call   801dcb <ipc_recv>
}
  800ca0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800cad:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb0:	8b 40 0c             	mov    0xc(%eax),%eax
  800cb3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc5:	b8 02 00 00 00       	mov    $0x2,%eax
  800cca:	e8 8d ff ff ff       	call   800c5c <fsipc>
}
  800ccf:	c9                   	leave  
  800cd0:	c3                   	ret    

00800cd1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cda:	8b 40 0c             	mov    0xc(%eax),%eax
  800cdd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ce2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce7:	b8 06 00 00 00       	mov    $0x6,%eax
  800cec:	e8 6b ff ff ff       	call   800c5c <fsipc>
}
  800cf1:	c9                   	leave  
  800cf2:	c3                   	ret    

00800cf3 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 04             	sub    $0x4,%esp
  800cfa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800d00:	8b 40 0c             	mov    0xc(%eax),%eax
  800d03:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d08:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d12:	e8 45 ff ff ff       	call   800c5c <fsipc>
  800d17:	85 c0                	test   %eax,%eax
  800d19:	78 2c                	js     800d47 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d1b:	83 ec 08             	sub    $0x8,%esp
  800d1e:	68 00 50 80 00       	push   $0x805000
  800d23:	53                   	push   %ebx
  800d24:	e8 cc 0c 00 00       	call   8019f5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d29:	a1 80 50 80 00       	mov    0x805080,%eax
  800d2e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d34:	a1 84 50 80 00       	mov    0x805084,%eax
  800d39:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d3f:	83 c4 10             	add    $0x10,%esp
  800d42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d4a:	c9                   	leave  
  800d4b:	c3                   	ret    

00800d4c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 0c             	sub    $0xc,%esp
  800d52:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	8b 52 0c             	mov    0xc(%edx),%edx
  800d5b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d61:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d66:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d6b:	0f 47 c2             	cmova  %edx,%eax
  800d6e:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d73:	50                   	push   %eax
  800d74:	ff 75 0c             	pushl  0xc(%ebp)
  800d77:	68 08 50 80 00       	push   $0x805008
  800d7c:	e8 06 0e 00 00       	call   801b87 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d81:	ba 00 00 00 00       	mov    $0x0,%edx
  800d86:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8b:	e8 cc fe ff ff       	call   800c5c <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800d90:	c9                   	leave  
  800d91:	c3                   	ret    

00800d92 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
  800d97:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9d:	8b 40 0c             	mov    0xc(%eax),%eax
  800da0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800da5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800dab:	ba 00 00 00 00       	mov    $0x0,%edx
  800db0:	b8 03 00 00 00       	mov    $0x3,%eax
  800db5:	e8 a2 fe ff ff       	call   800c5c <fsipc>
  800dba:	89 c3                	mov    %eax,%ebx
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	78 4b                	js     800e0b <devfile_read+0x79>
		return r;
	assert(r <= n);
  800dc0:	39 c6                	cmp    %eax,%esi
  800dc2:	73 16                	jae    800dda <devfile_read+0x48>
  800dc4:	68 00 23 80 00       	push   $0x802300
  800dc9:	68 07 23 80 00       	push   $0x802307
  800dce:	6a 7c                	push   $0x7c
  800dd0:	68 1c 23 80 00       	push   $0x80231c
  800dd5:	e8 bd 05 00 00       	call   801397 <_panic>
	assert(r <= PGSIZE);
  800dda:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ddf:	7e 16                	jle    800df7 <devfile_read+0x65>
  800de1:	68 27 23 80 00       	push   $0x802327
  800de6:	68 07 23 80 00       	push   $0x802307
  800deb:	6a 7d                	push   $0x7d
  800ded:	68 1c 23 80 00       	push   $0x80231c
  800df2:	e8 a0 05 00 00       	call   801397 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800df7:	83 ec 04             	sub    $0x4,%esp
  800dfa:	50                   	push   %eax
  800dfb:	68 00 50 80 00       	push   $0x805000
  800e00:	ff 75 0c             	pushl  0xc(%ebp)
  800e03:	e8 7f 0d 00 00       	call   801b87 <memmove>
	return r;
  800e08:	83 c4 10             	add    $0x10,%esp
}
  800e0b:	89 d8                	mov    %ebx,%eax
  800e0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	53                   	push   %ebx
  800e18:	83 ec 20             	sub    $0x20,%esp
  800e1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e1e:	53                   	push   %ebx
  800e1f:	e8 98 0b 00 00       	call   8019bc <strlen>
  800e24:	83 c4 10             	add    $0x10,%esp
  800e27:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e2c:	7f 67                	jg     800e95 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e2e:	83 ec 0c             	sub    $0xc,%esp
  800e31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e34:	50                   	push   %eax
  800e35:	e8 9a f8 ff ff       	call   8006d4 <fd_alloc>
  800e3a:	83 c4 10             	add    $0x10,%esp
		return r;
  800e3d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	78 57                	js     800e9a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e43:	83 ec 08             	sub    $0x8,%esp
  800e46:	53                   	push   %ebx
  800e47:	68 00 50 80 00       	push   $0x805000
  800e4c:	e8 a4 0b 00 00       	call   8019f5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e54:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e59:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e61:	e8 f6 fd ff ff       	call   800c5c <fsipc>
  800e66:	89 c3                	mov    %eax,%ebx
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	79 14                	jns    800e83 <open+0x6f>
		fd_close(fd, 0);
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	6a 00                	push   $0x0
  800e74:	ff 75 f4             	pushl  -0xc(%ebp)
  800e77:	e8 50 f9 ff ff       	call   8007cc <fd_close>
		return r;
  800e7c:	83 c4 10             	add    $0x10,%esp
  800e7f:	89 da                	mov    %ebx,%edx
  800e81:	eb 17                	jmp    800e9a <open+0x86>
	}

	return fd2num(fd);
  800e83:	83 ec 0c             	sub    $0xc,%esp
  800e86:	ff 75 f4             	pushl  -0xc(%ebp)
  800e89:	e8 1f f8 ff ff       	call   8006ad <fd2num>
  800e8e:	89 c2                	mov    %eax,%edx
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	eb 05                	jmp    800e9a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800e95:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800e9a:	89 d0                	mov    %edx,%eax
  800e9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    

00800ea1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ea7:	ba 00 00 00 00       	mov    $0x0,%edx
  800eac:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb1:	e8 a6 fd ff ff       	call   800c5c <fsipc>
}
  800eb6:	c9                   	leave  
  800eb7:	c3                   	ret    

00800eb8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	56                   	push   %esi
  800ebc:	53                   	push   %ebx
  800ebd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ec0:	83 ec 0c             	sub    $0xc,%esp
  800ec3:	ff 75 08             	pushl  0x8(%ebp)
  800ec6:	e8 f2 f7 ff ff       	call   8006bd <fd2data>
  800ecb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ecd:	83 c4 08             	add    $0x8,%esp
  800ed0:	68 33 23 80 00       	push   $0x802333
  800ed5:	53                   	push   %ebx
  800ed6:	e8 1a 0b 00 00       	call   8019f5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800edb:	8b 46 04             	mov    0x4(%esi),%eax
  800ede:	2b 06                	sub    (%esi),%eax
  800ee0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ee6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800eed:	00 00 00 
	stat->st_dev = &devpipe;
  800ef0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ef7:	30 80 00 
	return 0;
}
  800efa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	53                   	push   %ebx
  800f0a:	83 ec 0c             	sub    $0xc,%esp
  800f0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f10:	53                   	push   %ebx
  800f11:	6a 00                	push   $0x0
  800f13:	e8 f7 f2 ff ff       	call   80020f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f18:	89 1c 24             	mov    %ebx,(%esp)
  800f1b:	e8 9d f7 ff ff       	call   8006bd <fd2data>
  800f20:	83 c4 08             	add    $0x8,%esp
  800f23:	50                   	push   %eax
  800f24:	6a 00                	push   $0x0
  800f26:	e8 e4 f2 ff ff       	call   80020f <sys_page_unmap>
}
  800f2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2e:	c9                   	leave  
  800f2f:	c3                   	ret    

00800f30 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
  800f36:	83 ec 1c             	sub    $0x1c,%esp
  800f39:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f3c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f3e:	a1 04 40 80 00       	mov    0x804004,%eax
  800f43:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f46:	83 ec 0c             	sub    $0xc,%esp
  800f49:	ff 75 e0             	pushl  -0x20(%ebp)
  800f4c:	e8 94 0f 00 00       	call   801ee5 <pageref>
  800f51:	89 c3                	mov    %eax,%ebx
  800f53:	89 3c 24             	mov    %edi,(%esp)
  800f56:	e8 8a 0f 00 00       	call   801ee5 <pageref>
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	39 c3                	cmp    %eax,%ebx
  800f60:	0f 94 c1             	sete   %cl
  800f63:	0f b6 c9             	movzbl %cl,%ecx
  800f66:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f69:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f6f:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  800f72:	39 ce                	cmp    %ecx,%esi
  800f74:	74 1b                	je     800f91 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800f76:	39 c3                	cmp    %eax,%ebx
  800f78:	75 c4                	jne    800f3e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f7a:	8b 42 64             	mov    0x64(%edx),%eax
  800f7d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f80:	50                   	push   %eax
  800f81:	56                   	push   %esi
  800f82:	68 3a 23 80 00       	push   $0x80233a
  800f87:	e8 e4 04 00 00       	call   801470 <cprintf>
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	eb ad                	jmp    800f3e <_pipeisclosed+0xe>
	}
}
  800f91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	57                   	push   %edi
  800fa0:	56                   	push   %esi
  800fa1:	53                   	push   %ebx
  800fa2:	83 ec 28             	sub    $0x28,%esp
  800fa5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800fa8:	56                   	push   %esi
  800fa9:	e8 0f f7 ff ff       	call   8006bd <fd2data>
  800fae:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb8:	eb 4b                	jmp    801005 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fba:	89 da                	mov    %ebx,%edx
  800fbc:	89 f0                	mov    %esi,%eax
  800fbe:	e8 6d ff ff ff       	call   800f30 <_pipeisclosed>
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	75 48                	jne    80100f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fc7:	e8 9f f1 ff ff       	call   80016b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fcc:	8b 43 04             	mov    0x4(%ebx),%eax
  800fcf:	8b 0b                	mov    (%ebx),%ecx
  800fd1:	8d 51 20             	lea    0x20(%ecx),%edx
  800fd4:	39 d0                	cmp    %edx,%eax
  800fd6:	73 e2                	jae    800fba <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800fd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800fdf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800fe2:	89 c2                	mov    %eax,%edx
  800fe4:	c1 fa 1f             	sar    $0x1f,%edx
  800fe7:	89 d1                	mov    %edx,%ecx
  800fe9:	c1 e9 1b             	shr    $0x1b,%ecx
  800fec:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800fef:	83 e2 1f             	and    $0x1f,%edx
  800ff2:	29 ca                	sub    %ecx,%edx
  800ff4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ff8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ffc:	83 c0 01             	add    $0x1,%eax
  800fff:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801002:	83 c7 01             	add    $0x1,%edi
  801005:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801008:	75 c2                	jne    800fcc <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80100a:	8b 45 10             	mov    0x10(%ebp),%eax
  80100d:	eb 05                	jmp    801014 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80100f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801014:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801017:	5b                   	pop    %ebx
  801018:	5e                   	pop    %esi
  801019:	5f                   	pop    %edi
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	57                   	push   %edi
  801020:	56                   	push   %esi
  801021:	53                   	push   %ebx
  801022:	83 ec 18             	sub    $0x18,%esp
  801025:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801028:	57                   	push   %edi
  801029:	e8 8f f6 ff ff       	call   8006bd <fd2data>
  80102e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	bb 00 00 00 00       	mov    $0x0,%ebx
  801038:	eb 3d                	jmp    801077 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80103a:	85 db                	test   %ebx,%ebx
  80103c:	74 04                	je     801042 <devpipe_read+0x26>
				return i;
  80103e:	89 d8                	mov    %ebx,%eax
  801040:	eb 44                	jmp    801086 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801042:	89 f2                	mov    %esi,%edx
  801044:	89 f8                	mov    %edi,%eax
  801046:	e8 e5 fe ff ff       	call   800f30 <_pipeisclosed>
  80104b:	85 c0                	test   %eax,%eax
  80104d:	75 32                	jne    801081 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80104f:	e8 17 f1 ff ff       	call   80016b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801054:	8b 06                	mov    (%esi),%eax
  801056:	3b 46 04             	cmp    0x4(%esi),%eax
  801059:	74 df                	je     80103a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80105b:	99                   	cltd   
  80105c:	c1 ea 1b             	shr    $0x1b,%edx
  80105f:	01 d0                	add    %edx,%eax
  801061:	83 e0 1f             	and    $0x1f,%eax
  801064:	29 d0                	sub    %edx,%eax
  801066:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80106b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801071:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801074:	83 c3 01             	add    $0x1,%ebx
  801077:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80107a:	75 d8                	jne    801054 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80107c:	8b 45 10             	mov    0x10(%ebp),%eax
  80107f:	eb 05                	jmp    801086 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801081:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801086:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801089:	5b                   	pop    %ebx
  80108a:	5e                   	pop    %esi
  80108b:	5f                   	pop    %edi
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801096:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801099:	50                   	push   %eax
  80109a:	e8 35 f6 ff ff       	call   8006d4 <fd_alloc>
  80109f:	83 c4 10             	add    $0x10,%esp
  8010a2:	89 c2                	mov    %eax,%edx
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	0f 88 2c 01 00 00    	js     8011d8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010ac:	83 ec 04             	sub    $0x4,%esp
  8010af:	68 07 04 00 00       	push   $0x407
  8010b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b7:	6a 00                	push   $0x0
  8010b9:	e8 cc f0 ff ff       	call   80018a <sys_page_alloc>
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	89 c2                	mov    %eax,%edx
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	0f 88 0d 01 00 00    	js     8011d8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010cb:	83 ec 0c             	sub    $0xc,%esp
  8010ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d1:	50                   	push   %eax
  8010d2:	e8 fd f5 ff ff       	call   8006d4 <fd_alloc>
  8010d7:	89 c3                	mov    %eax,%ebx
  8010d9:	83 c4 10             	add    $0x10,%esp
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	0f 88 e2 00 00 00    	js     8011c6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010e4:	83 ec 04             	sub    $0x4,%esp
  8010e7:	68 07 04 00 00       	push   $0x407
  8010ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8010ef:	6a 00                	push   $0x0
  8010f1:	e8 94 f0 ff ff       	call   80018a <sys_page_alloc>
  8010f6:	89 c3                	mov    %eax,%ebx
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	0f 88 c3 00 00 00    	js     8011c6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	ff 75 f4             	pushl  -0xc(%ebp)
  801109:	e8 af f5 ff ff       	call   8006bd <fd2data>
  80110e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801110:	83 c4 0c             	add    $0xc,%esp
  801113:	68 07 04 00 00       	push   $0x407
  801118:	50                   	push   %eax
  801119:	6a 00                	push   $0x0
  80111b:	e8 6a f0 ff ff       	call   80018a <sys_page_alloc>
  801120:	89 c3                	mov    %eax,%ebx
  801122:	83 c4 10             	add    $0x10,%esp
  801125:	85 c0                	test   %eax,%eax
  801127:	0f 88 89 00 00 00    	js     8011b6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80112d:	83 ec 0c             	sub    $0xc,%esp
  801130:	ff 75 f0             	pushl  -0x10(%ebp)
  801133:	e8 85 f5 ff ff       	call   8006bd <fd2data>
  801138:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80113f:	50                   	push   %eax
  801140:	6a 00                	push   $0x0
  801142:	56                   	push   %esi
  801143:	6a 00                	push   $0x0
  801145:	e8 83 f0 ff ff       	call   8001cd <sys_page_map>
  80114a:	89 c3                	mov    %eax,%ebx
  80114c:	83 c4 20             	add    $0x20,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 55                	js     8011a8 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801153:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801159:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80115e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801161:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801168:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80116e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801171:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801173:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801176:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80117d:	83 ec 0c             	sub    $0xc,%esp
  801180:	ff 75 f4             	pushl  -0xc(%ebp)
  801183:	e8 25 f5 ff ff       	call   8006ad <fd2num>
  801188:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80118d:	83 c4 04             	add    $0x4,%esp
  801190:	ff 75 f0             	pushl  -0x10(%ebp)
  801193:	e8 15 f5 ff ff       	call   8006ad <fd2num>
  801198:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119b:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a6:	eb 30                	jmp    8011d8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011a8:	83 ec 08             	sub    $0x8,%esp
  8011ab:	56                   	push   %esi
  8011ac:	6a 00                	push   $0x0
  8011ae:	e8 5c f0 ff ff       	call   80020f <sys_page_unmap>
  8011b3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011b6:	83 ec 08             	sub    $0x8,%esp
  8011b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8011bc:	6a 00                	push   $0x0
  8011be:	e8 4c f0 ff ff       	call   80020f <sys_page_unmap>
  8011c3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011c6:	83 ec 08             	sub    $0x8,%esp
  8011c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8011cc:	6a 00                	push   $0x0
  8011ce:	e8 3c f0 ff ff       	call   80020f <sys_page_unmap>
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011d8:	89 d0                	mov    %edx,%eax
  8011da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ea:	50                   	push   %eax
  8011eb:	ff 75 08             	pushl  0x8(%ebp)
  8011ee:	e8 30 f5 ff ff       	call   800723 <fd_lookup>
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	78 18                	js     801212 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8011fa:	83 ec 0c             	sub    $0xc,%esp
  8011fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801200:	e8 b8 f4 ff ff       	call   8006bd <fd2data>
	return _pipeisclosed(fd, p);
  801205:	89 c2                	mov    %eax,%edx
  801207:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120a:	e8 21 fd ff ff       	call   800f30 <_pipeisclosed>
  80120f:	83 c4 10             	add    $0x10,%esp
}
  801212:	c9                   	leave  
  801213:	c3                   	ret    

00801214 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801217:	b8 00 00 00 00       	mov    $0x0,%eax
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801224:	68 52 23 80 00       	push   $0x802352
  801229:	ff 75 0c             	pushl  0xc(%ebp)
  80122c:	e8 c4 07 00 00       	call   8019f5 <strcpy>
	return 0;
}
  801231:	b8 00 00 00 00       	mov    $0x0,%eax
  801236:	c9                   	leave  
  801237:	c3                   	ret    

00801238 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	57                   	push   %edi
  80123c:	56                   	push   %esi
  80123d:	53                   	push   %ebx
  80123e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801244:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801249:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80124f:	eb 2d                	jmp    80127e <devcons_write+0x46>
		m = n - tot;
  801251:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801254:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801256:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801259:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80125e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801261:	83 ec 04             	sub    $0x4,%esp
  801264:	53                   	push   %ebx
  801265:	03 45 0c             	add    0xc(%ebp),%eax
  801268:	50                   	push   %eax
  801269:	57                   	push   %edi
  80126a:	e8 18 09 00 00       	call   801b87 <memmove>
		sys_cputs(buf, m);
  80126f:	83 c4 08             	add    $0x8,%esp
  801272:	53                   	push   %ebx
  801273:	57                   	push   %edi
  801274:	e8 55 ee ff ff       	call   8000ce <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801279:	01 de                	add    %ebx,%esi
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	89 f0                	mov    %esi,%eax
  801280:	3b 75 10             	cmp    0x10(%ebp),%esi
  801283:	72 cc                	jb     801251 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801285:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801288:	5b                   	pop    %ebx
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	83 ec 08             	sub    $0x8,%esp
  801293:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801298:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80129c:	74 2a                	je     8012c8 <devcons_read+0x3b>
  80129e:	eb 05                	jmp    8012a5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012a0:	e8 c6 ee ff ff       	call   80016b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012a5:	e8 42 ee ff ff       	call   8000ec <sys_cgetc>
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	74 f2                	je     8012a0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	78 16                	js     8012c8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012b2:	83 f8 04             	cmp    $0x4,%eax
  8012b5:	74 0c                	je     8012c3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ba:	88 02                	mov    %al,(%edx)
	return 1;
  8012bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8012c1:	eb 05                	jmp    8012c8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012c8:	c9                   	leave  
  8012c9:	c3                   	ret    

008012ca <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012d6:	6a 01                	push   $0x1
  8012d8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012db:	50                   	push   %eax
  8012dc:	e8 ed ed ff ff       	call   8000ce <sys_cputs>
}
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <getchar>:

int
getchar(void)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8012ec:	6a 01                	push   $0x1
  8012ee:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012f1:	50                   	push   %eax
  8012f2:	6a 00                	push   $0x0
  8012f4:	e8 90 f6 ff ff       	call   800989 <read>
	if (r < 0)
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 0f                	js     80130f <getchar+0x29>
		return r;
	if (r < 1)
  801300:	85 c0                	test   %eax,%eax
  801302:	7e 06                	jle    80130a <getchar+0x24>
		return -E_EOF;
	return c;
  801304:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801308:	eb 05                	jmp    80130f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80130a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80130f:	c9                   	leave  
  801310:	c3                   	ret    

00801311 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801317:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131a:	50                   	push   %eax
  80131b:	ff 75 08             	pushl  0x8(%ebp)
  80131e:	e8 00 f4 ff ff       	call   800723 <fd_lookup>
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	85 c0                	test   %eax,%eax
  801328:	78 11                	js     80133b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80132a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801333:	39 10                	cmp    %edx,(%eax)
  801335:	0f 94 c0             	sete   %al
  801338:	0f b6 c0             	movzbl %al,%eax
}
  80133b:	c9                   	leave  
  80133c:	c3                   	ret    

0080133d <opencons>:

int
opencons(void)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801343:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801346:	50                   	push   %eax
  801347:	e8 88 f3 ff ff       	call   8006d4 <fd_alloc>
  80134c:	83 c4 10             	add    $0x10,%esp
		return r;
  80134f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801351:	85 c0                	test   %eax,%eax
  801353:	78 3e                	js     801393 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801355:	83 ec 04             	sub    $0x4,%esp
  801358:	68 07 04 00 00       	push   $0x407
  80135d:	ff 75 f4             	pushl  -0xc(%ebp)
  801360:	6a 00                	push   $0x0
  801362:	e8 23 ee ff ff       	call   80018a <sys_page_alloc>
  801367:	83 c4 10             	add    $0x10,%esp
		return r;
  80136a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80136c:	85 c0                	test   %eax,%eax
  80136e:	78 23                	js     801393 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801370:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801376:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801379:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80137b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801385:	83 ec 0c             	sub    $0xc,%esp
  801388:	50                   	push   %eax
  801389:	e8 1f f3 ff ff       	call   8006ad <fd2num>
  80138e:	89 c2                	mov    %eax,%edx
  801390:	83 c4 10             	add    $0x10,%esp
}
  801393:	89 d0                	mov    %edx,%eax
  801395:	c9                   	leave  
  801396:	c3                   	ret    

00801397 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	56                   	push   %esi
  80139b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80139c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80139f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013a5:	e8 a2 ed ff ff       	call   80014c <sys_getenvid>
  8013aa:	83 ec 0c             	sub    $0xc,%esp
  8013ad:	ff 75 0c             	pushl  0xc(%ebp)
  8013b0:	ff 75 08             	pushl  0x8(%ebp)
  8013b3:	56                   	push   %esi
  8013b4:	50                   	push   %eax
  8013b5:	68 60 23 80 00       	push   $0x802360
  8013ba:	e8 b1 00 00 00       	call   801470 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013bf:	83 c4 18             	add    $0x18,%esp
  8013c2:	53                   	push   %ebx
  8013c3:	ff 75 10             	pushl  0x10(%ebp)
  8013c6:	e8 54 00 00 00       	call   80141f <vcprintf>
	cprintf("\n");
  8013cb:	c7 04 24 4b 23 80 00 	movl   $0x80234b,(%esp)
  8013d2:	e8 99 00 00 00       	call   801470 <cprintf>
  8013d7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013da:	cc                   	int3   
  8013db:	eb fd                	jmp    8013da <_panic+0x43>

008013dd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	53                   	push   %ebx
  8013e1:	83 ec 04             	sub    $0x4,%esp
  8013e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013e7:	8b 13                	mov    (%ebx),%edx
  8013e9:	8d 42 01             	lea    0x1(%edx),%eax
  8013ec:	89 03                	mov    %eax,(%ebx)
  8013ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013f5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013fa:	75 1a                	jne    801416 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	68 ff 00 00 00       	push   $0xff
  801404:	8d 43 08             	lea    0x8(%ebx),%eax
  801407:	50                   	push   %eax
  801408:	e8 c1 ec ff ff       	call   8000ce <sys_cputs>
		b->idx = 0;
  80140d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801413:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801416:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80141a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801428:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80142f:	00 00 00 
	b.cnt = 0;
  801432:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801439:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80143c:	ff 75 0c             	pushl  0xc(%ebp)
  80143f:	ff 75 08             	pushl  0x8(%ebp)
  801442:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	68 dd 13 80 00       	push   $0x8013dd
  80144e:	e8 54 01 00 00       	call   8015a7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801453:	83 c4 08             	add    $0x8,%esp
  801456:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80145c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801462:	50                   	push   %eax
  801463:	e8 66 ec ff ff       	call   8000ce <sys_cputs>

	return b.cnt;
}
  801468:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80146e:	c9                   	leave  
  80146f:	c3                   	ret    

00801470 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801476:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801479:	50                   	push   %eax
  80147a:	ff 75 08             	pushl  0x8(%ebp)
  80147d:	e8 9d ff ff ff       	call   80141f <vcprintf>
	va_end(ap);

	return cnt;
}
  801482:	c9                   	leave  
  801483:	c3                   	ret    

00801484 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	57                   	push   %edi
  801488:	56                   	push   %esi
  801489:	53                   	push   %ebx
  80148a:	83 ec 1c             	sub    $0x1c,%esp
  80148d:	89 c7                	mov    %eax,%edi
  80148f:	89 d6                	mov    %edx,%esi
  801491:	8b 45 08             	mov    0x8(%ebp),%eax
  801494:	8b 55 0c             	mov    0xc(%ebp),%edx
  801497:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80149a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80149d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014a8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014ab:	39 d3                	cmp    %edx,%ebx
  8014ad:	72 05                	jb     8014b4 <printnum+0x30>
  8014af:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014b2:	77 45                	ja     8014f9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014b4:	83 ec 0c             	sub    $0xc,%esp
  8014b7:	ff 75 18             	pushl  0x18(%ebp)
  8014ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014c0:	53                   	push   %ebx
  8014c1:	ff 75 10             	pushl  0x10(%ebp)
  8014c4:	83 ec 08             	sub    $0x8,%esp
  8014c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8014cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8014d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8014d3:	e8 48 0a 00 00       	call   801f20 <__udivdi3>
  8014d8:	83 c4 18             	add    $0x18,%esp
  8014db:	52                   	push   %edx
  8014dc:	50                   	push   %eax
  8014dd:	89 f2                	mov    %esi,%edx
  8014df:	89 f8                	mov    %edi,%eax
  8014e1:	e8 9e ff ff ff       	call   801484 <printnum>
  8014e6:	83 c4 20             	add    $0x20,%esp
  8014e9:	eb 18                	jmp    801503 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014eb:	83 ec 08             	sub    $0x8,%esp
  8014ee:	56                   	push   %esi
  8014ef:	ff 75 18             	pushl  0x18(%ebp)
  8014f2:	ff d7                	call   *%edi
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	eb 03                	jmp    8014fc <printnum+0x78>
  8014f9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014fc:	83 eb 01             	sub    $0x1,%ebx
  8014ff:	85 db                	test   %ebx,%ebx
  801501:	7f e8                	jg     8014eb <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	56                   	push   %esi
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80150d:	ff 75 e0             	pushl  -0x20(%ebp)
  801510:	ff 75 dc             	pushl  -0x24(%ebp)
  801513:	ff 75 d8             	pushl  -0x28(%ebp)
  801516:	e8 35 0b 00 00       	call   802050 <__umoddi3>
  80151b:	83 c4 14             	add    $0x14,%esp
  80151e:	0f be 80 83 23 80 00 	movsbl 0x802383(%eax),%eax
  801525:	50                   	push   %eax
  801526:	ff d7                	call   *%edi
}
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152e:	5b                   	pop    %ebx
  80152f:	5e                   	pop    %esi
  801530:	5f                   	pop    %edi
  801531:	5d                   	pop    %ebp
  801532:	c3                   	ret    

00801533 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801536:	83 fa 01             	cmp    $0x1,%edx
  801539:	7e 0e                	jle    801549 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80153b:	8b 10                	mov    (%eax),%edx
  80153d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801540:	89 08                	mov    %ecx,(%eax)
  801542:	8b 02                	mov    (%edx),%eax
  801544:	8b 52 04             	mov    0x4(%edx),%edx
  801547:	eb 22                	jmp    80156b <getuint+0x38>
	else if (lflag)
  801549:	85 d2                	test   %edx,%edx
  80154b:	74 10                	je     80155d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80154d:	8b 10                	mov    (%eax),%edx
  80154f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801552:	89 08                	mov    %ecx,(%eax)
  801554:	8b 02                	mov    (%edx),%eax
  801556:	ba 00 00 00 00       	mov    $0x0,%edx
  80155b:	eb 0e                	jmp    80156b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80155d:	8b 10                	mov    (%eax),%edx
  80155f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801562:	89 08                	mov    %ecx,(%eax)
  801564:	8b 02                	mov    (%edx),%eax
  801566:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80156b:	5d                   	pop    %ebp
  80156c:	c3                   	ret    

0080156d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801573:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801577:	8b 10                	mov    (%eax),%edx
  801579:	3b 50 04             	cmp    0x4(%eax),%edx
  80157c:	73 0a                	jae    801588 <sprintputch+0x1b>
		*b->buf++ = ch;
  80157e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801581:	89 08                	mov    %ecx,(%eax)
  801583:	8b 45 08             	mov    0x8(%ebp),%eax
  801586:	88 02                	mov    %al,(%edx)
}
  801588:	5d                   	pop    %ebp
  801589:	c3                   	ret    

0080158a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801590:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801593:	50                   	push   %eax
  801594:	ff 75 10             	pushl  0x10(%ebp)
  801597:	ff 75 0c             	pushl  0xc(%ebp)
  80159a:	ff 75 08             	pushl  0x8(%ebp)
  80159d:	e8 05 00 00 00       	call   8015a7 <vprintfmt>
	va_end(ap);
}
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	c9                   	leave  
  8015a6:	c3                   	ret    

008015a7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	57                   	push   %edi
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 2c             	sub    $0x2c,%esp
  8015b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015b6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015b9:	eb 12                	jmp    8015cd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	0f 84 89 03 00 00    	je     80194c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	53                   	push   %ebx
  8015c7:	50                   	push   %eax
  8015c8:	ff d6                	call   *%esi
  8015ca:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015cd:	83 c7 01             	add    $0x1,%edi
  8015d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015d4:	83 f8 25             	cmp    $0x25,%eax
  8015d7:	75 e2                	jne    8015bb <vprintfmt+0x14>
  8015d9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015dd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8015eb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8015f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f7:	eb 07                	jmp    801600 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8015fc:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801600:	8d 47 01             	lea    0x1(%edi),%eax
  801603:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801606:	0f b6 07             	movzbl (%edi),%eax
  801609:	0f b6 c8             	movzbl %al,%ecx
  80160c:	83 e8 23             	sub    $0x23,%eax
  80160f:	3c 55                	cmp    $0x55,%al
  801611:	0f 87 1a 03 00 00    	ja     801931 <vprintfmt+0x38a>
  801617:	0f b6 c0             	movzbl %al,%eax
  80161a:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  801621:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801624:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801628:	eb d6                	jmp    801600 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80162a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80162d:	b8 00 00 00 00       	mov    $0x0,%eax
  801632:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801635:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801638:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80163c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80163f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801642:	83 fa 09             	cmp    $0x9,%edx
  801645:	77 39                	ja     801680 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801647:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80164a:	eb e9                	jmp    801635 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80164c:	8b 45 14             	mov    0x14(%ebp),%eax
  80164f:	8d 48 04             	lea    0x4(%eax),%ecx
  801652:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801655:	8b 00                	mov    (%eax),%eax
  801657:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80165a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80165d:	eb 27                	jmp    801686 <vprintfmt+0xdf>
  80165f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801662:	85 c0                	test   %eax,%eax
  801664:	b9 00 00 00 00       	mov    $0x0,%ecx
  801669:	0f 49 c8             	cmovns %eax,%ecx
  80166c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80166f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801672:	eb 8c                	jmp    801600 <vprintfmt+0x59>
  801674:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801677:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80167e:	eb 80                	jmp    801600 <vprintfmt+0x59>
  801680:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801683:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801686:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80168a:	0f 89 70 ff ff ff    	jns    801600 <vprintfmt+0x59>
				width = precision, precision = -1;
  801690:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801693:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801696:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80169d:	e9 5e ff ff ff       	jmp    801600 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016a2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016a8:	e9 53 ff ff ff       	jmp    801600 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b0:	8d 50 04             	lea    0x4(%eax),%edx
  8016b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8016b6:	83 ec 08             	sub    $0x8,%esp
  8016b9:	53                   	push   %ebx
  8016ba:	ff 30                	pushl  (%eax)
  8016bc:	ff d6                	call   *%esi
			break;
  8016be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016c4:	e9 04 ff ff ff       	jmp    8015cd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8016cc:	8d 50 04             	lea    0x4(%eax),%edx
  8016cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8016d2:	8b 00                	mov    (%eax),%eax
  8016d4:	99                   	cltd   
  8016d5:	31 d0                	xor    %edx,%eax
  8016d7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016d9:	83 f8 0f             	cmp    $0xf,%eax
  8016dc:	7f 0b                	jg     8016e9 <vprintfmt+0x142>
  8016de:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8016e5:	85 d2                	test   %edx,%edx
  8016e7:	75 18                	jne    801701 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8016e9:	50                   	push   %eax
  8016ea:	68 9b 23 80 00       	push   $0x80239b
  8016ef:	53                   	push   %ebx
  8016f0:	56                   	push   %esi
  8016f1:	e8 94 fe ff ff       	call   80158a <printfmt>
  8016f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8016fc:	e9 cc fe ff ff       	jmp    8015cd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801701:	52                   	push   %edx
  801702:	68 19 23 80 00       	push   $0x802319
  801707:	53                   	push   %ebx
  801708:	56                   	push   %esi
  801709:	e8 7c fe ff ff       	call   80158a <printfmt>
  80170e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801711:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801714:	e9 b4 fe ff ff       	jmp    8015cd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801719:	8b 45 14             	mov    0x14(%ebp),%eax
  80171c:	8d 50 04             	lea    0x4(%eax),%edx
  80171f:	89 55 14             	mov    %edx,0x14(%ebp)
  801722:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801724:	85 ff                	test   %edi,%edi
  801726:	b8 94 23 80 00       	mov    $0x802394,%eax
  80172b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80172e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801732:	0f 8e 94 00 00 00    	jle    8017cc <vprintfmt+0x225>
  801738:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80173c:	0f 84 98 00 00 00    	je     8017da <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801742:	83 ec 08             	sub    $0x8,%esp
  801745:	ff 75 d0             	pushl  -0x30(%ebp)
  801748:	57                   	push   %edi
  801749:	e8 86 02 00 00       	call   8019d4 <strnlen>
  80174e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801751:	29 c1                	sub    %eax,%ecx
  801753:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801756:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801759:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80175d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801760:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801763:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801765:	eb 0f                	jmp    801776 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	53                   	push   %ebx
  80176b:	ff 75 e0             	pushl  -0x20(%ebp)
  80176e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801770:	83 ef 01             	sub    $0x1,%edi
  801773:	83 c4 10             	add    $0x10,%esp
  801776:	85 ff                	test   %edi,%edi
  801778:	7f ed                	jg     801767 <vprintfmt+0x1c0>
  80177a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80177d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801780:	85 c9                	test   %ecx,%ecx
  801782:	b8 00 00 00 00       	mov    $0x0,%eax
  801787:	0f 49 c1             	cmovns %ecx,%eax
  80178a:	29 c1                	sub    %eax,%ecx
  80178c:	89 75 08             	mov    %esi,0x8(%ebp)
  80178f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801792:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801795:	89 cb                	mov    %ecx,%ebx
  801797:	eb 4d                	jmp    8017e6 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801799:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80179d:	74 1b                	je     8017ba <vprintfmt+0x213>
  80179f:	0f be c0             	movsbl %al,%eax
  8017a2:	83 e8 20             	sub    $0x20,%eax
  8017a5:	83 f8 5e             	cmp    $0x5e,%eax
  8017a8:	76 10                	jbe    8017ba <vprintfmt+0x213>
					putch('?', putdat);
  8017aa:	83 ec 08             	sub    $0x8,%esp
  8017ad:	ff 75 0c             	pushl  0xc(%ebp)
  8017b0:	6a 3f                	push   $0x3f
  8017b2:	ff 55 08             	call   *0x8(%ebp)
  8017b5:	83 c4 10             	add    $0x10,%esp
  8017b8:	eb 0d                	jmp    8017c7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017ba:	83 ec 08             	sub    $0x8,%esp
  8017bd:	ff 75 0c             	pushl  0xc(%ebp)
  8017c0:	52                   	push   %edx
  8017c1:	ff 55 08             	call   *0x8(%ebp)
  8017c4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017c7:	83 eb 01             	sub    $0x1,%ebx
  8017ca:	eb 1a                	jmp    8017e6 <vprintfmt+0x23f>
  8017cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8017cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017d5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017d8:	eb 0c                	jmp    8017e6 <vprintfmt+0x23f>
  8017da:	89 75 08             	mov    %esi,0x8(%ebp)
  8017dd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017e3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017e6:	83 c7 01             	add    $0x1,%edi
  8017e9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017ed:	0f be d0             	movsbl %al,%edx
  8017f0:	85 d2                	test   %edx,%edx
  8017f2:	74 23                	je     801817 <vprintfmt+0x270>
  8017f4:	85 f6                	test   %esi,%esi
  8017f6:	78 a1                	js     801799 <vprintfmt+0x1f2>
  8017f8:	83 ee 01             	sub    $0x1,%esi
  8017fb:	79 9c                	jns    801799 <vprintfmt+0x1f2>
  8017fd:	89 df                	mov    %ebx,%edi
  8017ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801805:	eb 18                	jmp    80181f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801807:	83 ec 08             	sub    $0x8,%esp
  80180a:	53                   	push   %ebx
  80180b:	6a 20                	push   $0x20
  80180d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80180f:	83 ef 01             	sub    $0x1,%edi
  801812:	83 c4 10             	add    $0x10,%esp
  801815:	eb 08                	jmp    80181f <vprintfmt+0x278>
  801817:	89 df                	mov    %ebx,%edi
  801819:	8b 75 08             	mov    0x8(%ebp),%esi
  80181c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80181f:	85 ff                	test   %edi,%edi
  801821:	7f e4                	jg     801807 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801823:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801826:	e9 a2 fd ff ff       	jmp    8015cd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80182b:	83 fa 01             	cmp    $0x1,%edx
  80182e:	7e 16                	jle    801846 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801830:	8b 45 14             	mov    0x14(%ebp),%eax
  801833:	8d 50 08             	lea    0x8(%eax),%edx
  801836:	89 55 14             	mov    %edx,0x14(%ebp)
  801839:	8b 50 04             	mov    0x4(%eax),%edx
  80183c:	8b 00                	mov    (%eax),%eax
  80183e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801841:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801844:	eb 32                	jmp    801878 <vprintfmt+0x2d1>
	else if (lflag)
  801846:	85 d2                	test   %edx,%edx
  801848:	74 18                	je     801862 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80184a:	8b 45 14             	mov    0x14(%ebp),%eax
  80184d:	8d 50 04             	lea    0x4(%eax),%edx
  801850:	89 55 14             	mov    %edx,0x14(%ebp)
  801853:	8b 00                	mov    (%eax),%eax
  801855:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801858:	89 c1                	mov    %eax,%ecx
  80185a:	c1 f9 1f             	sar    $0x1f,%ecx
  80185d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801860:	eb 16                	jmp    801878 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801862:	8b 45 14             	mov    0x14(%ebp),%eax
  801865:	8d 50 04             	lea    0x4(%eax),%edx
  801868:	89 55 14             	mov    %edx,0x14(%ebp)
  80186b:	8b 00                	mov    (%eax),%eax
  80186d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801870:	89 c1                	mov    %eax,%ecx
  801872:	c1 f9 1f             	sar    $0x1f,%ecx
  801875:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801878:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80187b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80187e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801883:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801887:	79 74                	jns    8018fd <vprintfmt+0x356>
				putch('-', putdat);
  801889:	83 ec 08             	sub    $0x8,%esp
  80188c:	53                   	push   %ebx
  80188d:	6a 2d                	push   $0x2d
  80188f:	ff d6                	call   *%esi
				num = -(long long) num;
  801891:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801894:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801897:	f7 d8                	neg    %eax
  801899:	83 d2 00             	adc    $0x0,%edx
  80189c:	f7 da                	neg    %edx
  80189e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018a1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018a6:	eb 55                	jmp    8018fd <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8018ab:	e8 83 fc ff ff       	call   801533 <getuint>
			base = 10;
  8018b0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018b5:	eb 46                	jmp    8018fd <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8018ba:	e8 74 fc ff ff       	call   801533 <getuint>
			base = 8;
  8018bf:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018c4:	eb 37                	jmp    8018fd <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018c6:	83 ec 08             	sub    $0x8,%esp
  8018c9:	53                   	push   %ebx
  8018ca:	6a 30                	push   $0x30
  8018cc:	ff d6                	call   *%esi
			putch('x', putdat);
  8018ce:	83 c4 08             	add    $0x8,%esp
  8018d1:	53                   	push   %ebx
  8018d2:	6a 78                	push   $0x78
  8018d4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d9:	8d 50 04             	lea    0x4(%eax),%edx
  8018dc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018df:	8b 00                	mov    (%eax),%eax
  8018e1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018e6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8018e9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8018ee:	eb 0d                	jmp    8018fd <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8018f3:	e8 3b fc ff ff       	call   801533 <getuint>
			base = 16;
  8018f8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018fd:	83 ec 0c             	sub    $0xc,%esp
  801900:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801904:	57                   	push   %edi
  801905:	ff 75 e0             	pushl  -0x20(%ebp)
  801908:	51                   	push   %ecx
  801909:	52                   	push   %edx
  80190a:	50                   	push   %eax
  80190b:	89 da                	mov    %ebx,%edx
  80190d:	89 f0                	mov    %esi,%eax
  80190f:	e8 70 fb ff ff       	call   801484 <printnum>
			break;
  801914:	83 c4 20             	add    $0x20,%esp
  801917:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80191a:	e9 ae fc ff ff       	jmp    8015cd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80191f:	83 ec 08             	sub    $0x8,%esp
  801922:	53                   	push   %ebx
  801923:	51                   	push   %ecx
  801924:	ff d6                	call   *%esi
			break;
  801926:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801929:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80192c:	e9 9c fc ff ff       	jmp    8015cd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801931:	83 ec 08             	sub    $0x8,%esp
  801934:	53                   	push   %ebx
  801935:	6a 25                	push   $0x25
  801937:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	eb 03                	jmp    801941 <vprintfmt+0x39a>
  80193e:	83 ef 01             	sub    $0x1,%edi
  801941:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801945:	75 f7                	jne    80193e <vprintfmt+0x397>
  801947:	e9 81 fc ff ff       	jmp    8015cd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80194c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80194f:	5b                   	pop    %ebx
  801950:	5e                   	pop    %esi
  801951:	5f                   	pop    %edi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	83 ec 18             	sub    $0x18,%esp
  80195a:	8b 45 08             	mov    0x8(%ebp),%eax
  80195d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801960:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801963:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801967:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80196a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801971:	85 c0                	test   %eax,%eax
  801973:	74 26                	je     80199b <vsnprintf+0x47>
  801975:	85 d2                	test   %edx,%edx
  801977:	7e 22                	jle    80199b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801979:	ff 75 14             	pushl  0x14(%ebp)
  80197c:	ff 75 10             	pushl  0x10(%ebp)
  80197f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801982:	50                   	push   %eax
  801983:	68 6d 15 80 00       	push   $0x80156d
  801988:	e8 1a fc ff ff       	call   8015a7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80198d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801990:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801993:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801996:	83 c4 10             	add    $0x10,%esp
  801999:	eb 05                	jmp    8019a0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80199b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019a8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019ab:	50                   	push   %eax
  8019ac:	ff 75 10             	pushl  0x10(%ebp)
  8019af:	ff 75 0c             	pushl  0xc(%ebp)
  8019b2:	ff 75 08             	pushl  0x8(%ebp)
  8019b5:	e8 9a ff ff ff       	call   801954 <vsnprintf>
	va_end(ap);

	return rc;
}
  8019ba:	c9                   	leave  
  8019bb:	c3                   	ret    

008019bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c7:	eb 03                	jmp    8019cc <strlen+0x10>
		n++;
  8019c9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019cc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019d0:	75 f7                	jne    8019c9 <strlen+0xd>
		n++;
	return n;
}
  8019d2:	5d                   	pop    %ebp
  8019d3:	c3                   	ret    

008019d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019da:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e2:	eb 03                	jmp    8019e7 <strnlen+0x13>
		n++;
  8019e4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019e7:	39 c2                	cmp    %eax,%edx
  8019e9:	74 08                	je     8019f3 <strnlen+0x1f>
  8019eb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8019ef:	75 f3                	jne    8019e4 <strnlen+0x10>
  8019f1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8019f3:	5d                   	pop    %ebp
  8019f4:	c3                   	ret    

008019f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	53                   	push   %ebx
  8019f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8019ff:	89 c2                	mov    %eax,%edx
  801a01:	83 c2 01             	add    $0x1,%edx
  801a04:	83 c1 01             	add    $0x1,%ecx
  801a07:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a0b:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a0e:	84 db                	test   %bl,%bl
  801a10:	75 ef                	jne    801a01 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a12:	5b                   	pop    %ebx
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    

00801a15 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	53                   	push   %ebx
  801a19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a1c:	53                   	push   %ebx
  801a1d:	e8 9a ff ff ff       	call   8019bc <strlen>
  801a22:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a25:	ff 75 0c             	pushl  0xc(%ebp)
  801a28:	01 d8                	add    %ebx,%eax
  801a2a:	50                   	push   %eax
  801a2b:	e8 c5 ff ff ff       	call   8019f5 <strcpy>
	return dst;
}
  801a30:	89 d8                	mov    %ebx,%eax
  801a32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a35:	c9                   	leave  
  801a36:	c3                   	ret    

00801a37 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	56                   	push   %esi
  801a3b:	53                   	push   %ebx
  801a3c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a42:	89 f3                	mov    %esi,%ebx
  801a44:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a47:	89 f2                	mov    %esi,%edx
  801a49:	eb 0f                	jmp    801a5a <strncpy+0x23>
		*dst++ = *src;
  801a4b:	83 c2 01             	add    $0x1,%edx
  801a4e:	0f b6 01             	movzbl (%ecx),%eax
  801a51:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a54:	80 39 01             	cmpb   $0x1,(%ecx)
  801a57:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a5a:	39 da                	cmp    %ebx,%edx
  801a5c:	75 ed                	jne    801a4b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a5e:	89 f0                	mov    %esi,%eax
  801a60:	5b                   	pop    %ebx
  801a61:	5e                   	pop    %esi
  801a62:	5d                   	pop    %ebp
  801a63:	c3                   	ret    

00801a64 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	56                   	push   %esi
  801a68:	53                   	push   %ebx
  801a69:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6f:	8b 55 10             	mov    0x10(%ebp),%edx
  801a72:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a74:	85 d2                	test   %edx,%edx
  801a76:	74 21                	je     801a99 <strlcpy+0x35>
  801a78:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a7c:	89 f2                	mov    %esi,%edx
  801a7e:	eb 09                	jmp    801a89 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a80:	83 c2 01             	add    $0x1,%edx
  801a83:	83 c1 01             	add    $0x1,%ecx
  801a86:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a89:	39 c2                	cmp    %eax,%edx
  801a8b:	74 09                	je     801a96 <strlcpy+0x32>
  801a8d:	0f b6 19             	movzbl (%ecx),%ebx
  801a90:	84 db                	test   %bl,%bl
  801a92:	75 ec                	jne    801a80 <strlcpy+0x1c>
  801a94:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a96:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801a99:	29 f0                	sub    %esi,%eax
}
  801a9b:	5b                   	pop    %ebx
  801a9c:	5e                   	pop    %esi
  801a9d:	5d                   	pop    %ebp
  801a9e:	c3                   	ret    

00801a9f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801aa8:	eb 06                	jmp    801ab0 <strcmp+0x11>
		p++, q++;
  801aaa:	83 c1 01             	add    $0x1,%ecx
  801aad:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801ab0:	0f b6 01             	movzbl (%ecx),%eax
  801ab3:	84 c0                	test   %al,%al
  801ab5:	74 04                	je     801abb <strcmp+0x1c>
  801ab7:	3a 02                	cmp    (%edx),%al
  801ab9:	74 ef                	je     801aaa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801abb:	0f b6 c0             	movzbl %al,%eax
  801abe:	0f b6 12             	movzbl (%edx),%edx
  801ac1:	29 d0                	sub    %edx,%eax
}
  801ac3:	5d                   	pop    %ebp
  801ac4:	c3                   	ret    

00801ac5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	53                   	push   %ebx
  801ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  801acc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801acf:	89 c3                	mov    %eax,%ebx
  801ad1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ad4:	eb 06                	jmp    801adc <strncmp+0x17>
		n--, p++, q++;
  801ad6:	83 c0 01             	add    $0x1,%eax
  801ad9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801adc:	39 d8                	cmp    %ebx,%eax
  801ade:	74 15                	je     801af5 <strncmp+0x30>
  801ae0:	0f b6 08             	movzbl (%eax),%ecx
  801ae3:	84 c9                	test   %cl,%cl
  801ae5:	74 04                	je     801aeb <strncmp+0x26>
  801ae7:	3a 0a                	cmp    (%edx),%cl
  801ae9:	74 eb                	je     801ad6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801aeb:	0f b6 00             	movzbl (%eax),%eax
  801aee:	0f b6 12             	movzbl (%edx),%edx
  801af1:	29 d0                	sub    %edx,%eax
  801af3:	eb 05                	jmp    801afa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801af5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801afa:	5b                   	pop    %ebx
  801afb:	5d                   	pop    %ebp
  801afc:	c3                   	ret    

00801afd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	8b 45 08             	mov    0x8(%ebp),%eax
  801b03:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b07:	eb 07                	jmp    801b10 <strchr+0x13>
		if (*s == c)
  801b09:	38 ca                	cmp    %cl,%dl
  801b0b:	74 0f                	je     801b1c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b0d:	83 c0 01             	add    $0x1,%eax
  801b10:	0f b6 10             	movzbl (%eax),%edx
  801b13:	84 d2                	test   %dl,%dl
  801b15:	75 f2                	jne    801b09 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b1c:	5d                   	pop    %ebp
  801b1d:	c3                   	ret    

00801b1e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	8b 45 08             	mov    0x8(%ebp),%eax
  801b24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b28:	eb 03                	jmp    801b2d <strfind+0xf>
  801b2a:	83 c0 01             	add    $0x1,%eax
  801b2d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b30:	38 ca                	cmp    %cl,%dl
  801b32:	74 04                	je     801b38 <strfind+0x1a>
  801b34:	84 d2                	test   %dl,%dl
  801b36:	75 f2                	jne    801b2a <strfind+0xc>
			break;
	return (char *) s;
}
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    

00801b3a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	57                   	push   %edi
  801b3e:	56                   	push   %esi
  801b3f:	53                   	push   %ebx
  801b40:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b43:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b46:	85 c9                	test   %ecx,%ecx
  801b48:	74 36                	je     801b80 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b4a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b50:	75 28                	jne    801b7a <memset+0x40>
  801b52:	f6 c1 03             	test   $0x3,%cl
  801b55:	75 23                	jne    801b7a <memset+0x40>
		c &= 0xFF;
  801b57:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b5b:	89 d3                	mov    %edx,%ebx
  801b5d:	c1 e3 08             	shl    $0x8,%ebx
  801b60:	89 d6                	mov    %edx,%esi
  801b62:	c1 e6 18             	shl    $0x18,%esi
  801b65:	89 d0                	mov    %edx,%eax
  801b67:	c1 e0 10             	shl    $0x10,%eax
  801b6a:	09 f0                	or     %esi,%eax
  801b6c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b6e:	89 d8                	mov    %ebx,%eax
  801b70:	09 d0                	or     %edx,%eax
  801b72:	c1 e9 02             	shr    $0x2,%ecx
  801b75:	fc                   	cld    
  801b76:	f3 ab                	rep stos %eax,%es:(%edi)
  801b78:	eb 06                	jmp    801b80 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7d:	fc                   	cld    
  801b7e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b80:	89 f8                	mov    %edi,%eax
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5f                   	pop    %edi
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	57                   	push   %edi
  801b8b:	56                   	push   %esi
  801b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b95:	39 c6                	cmp    %eax,%esi
  801b97:	73 35                	jae    801bce <memmove+0x47>
  801b99:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b9c:	39 d0                	cmp    %edx,%eax
  801b9e:	73 2e                	jae    801bce <memmove+0x47>
		s += n;
		d += n;
  801ba0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ba3:	89 d6                	mov    %edx,%esi
  801ba5:	09 fe                	or     %edi,%esi
  801ba7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801bad:	75 13                	jne    801bc2 <memmove+0x3b>
  801baf:	f6 c1 03             	test   $0x3,%cl
  801bb2:	75 0e                	jne    801bc2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bb4:	83 ef 04             	sub    $0x4,%edi
  801bb7:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bba:	c1 e9 02             	shr    $0x2,%ecx
  801bbd:	fd                   	std    
  801bbe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bc0:	eb 09                	jmp    801bcb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bc2:	83 ef 01             	sub    $0x1,%edi
  801bc5:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bc8:	fd                   	std    
  801bc9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bcb:	fc                   	cld    
  801bcc:	eb 1d                	jmp    801beb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bce:	89 f2                	mov    %esi,%edx
  801bd0:	09 c2                	or     %eax,%edx
  801bd2:	f6 c2 03             	test   $0x3,%dl
  801bd5:	75 0f                	jne    801be6 <memmove+0x5f>
  801bd7:	f6 c1 03             	test   $0x3,%cl
  801bda:	75 0a                	jne    801be6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801bdc:	c1 e9 02             	shr    $0x2,%ecx
  801bdf:	89 c7                	mov    %eax,%edi
  801be1:	fc                   	cld    
  801be2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801be4:	eb 05                	jmp    801beb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801be6:	89 c7                	mov    %eax,%edi
  801be8:	fc                   	cld    
  801be9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801beb:	5e                   	pop    %esi
  801bec:	5f                   	pop    %edi
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    

00801bef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801bf2:	ff 75 10             	pushl  0x10(%ebp)
  801bf5:	ff 75 0c             	pushl  0xc(%ebp)
  801bf8:	ff 75 08             	pushl  0x8(%ebp)
  801bfb:	e8 87 ff ff ff       	call   801b87 <memmove>
}
  801c00:	c9                   	leave  
  801c01:	c3                   	ret    

00801c02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	56                   	push   %esi
  801c06:	53                   	push   %ebx
  801c07:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c0d:	89 c6                	mov    %eax,%esi
  801c0f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c12:	eb 1a                	jmp    801c2e <memcmp+0x2c>
		if (*s1 != *s2)
  801c14:	0f b6 08             	movzbl (%eax),%ecx
  801c17:	0f b6 1a             	movzbl (%edx),%ebx
  801c1a:	38 d9                	cmp    %bl,%cl
  801c1c:	74 0a                	je     801c28 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c1e:	0f b6 c1             	movzbl %cl,%eax
  801c21:	0f b6 db             	movzbl %bl,%ebx
  801c24:	29 d8                	sub    %ebx,%eax
  801c26:	eb 0f                	jmp    801c37 <memcmp+0x35>
		s1++, s2++;
  801c28:	83 c0 01             	add    $0x1,%eax
  801c2b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c2e:	39 f0                	cmp    %esi,%eax
  801c30:	75 e2                	jne    801c14 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c37:	5b                   	pop    %ebx
  801c38:	5e                   	pop    %esi
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	53                   	push   %ebx
  801c3f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c42:	89 c1                	mov    %eax,%ecx
  801c44:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c47:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c4b:	eb 0a                	jmp    801c57 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c4d:	0f b6 10             	movzbl (%eax),%edx
  801c50:	39 da                	cmp    %ebx,%edx
  801c52:	74 07                	je     801c5b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c54:	83 c0 01             	add    $0x1,%eax
  801c57:	39 c8                	cmp    %ecx,%eax
  801c59:	72 f2                	jb     801c4d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c5b:	5b                   	pop    %ebx
  801c5c:	5d                   	pop    %ebp
  801c5d:	c3                   	ret    

00801c5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c6a:	eb 03                	jmp    801c6f <strtol+0x11>
		s++;
  801c6c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c6f:	0f b6 01             	movzbl (%ecx),%eax
  801c72:	3c 20                	cmp    $0x20,%al
  801c74:	74 f6                	je     801c6c <strtol+0xe>
  801c76:	3c 09                	cmp    $0x9,%al
  801c78:	74 f2                	je     801c6c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c7a:	3c 2b                	cmp    $0x2b,%al
  801c7c:	75 0a                	jne    801c88 <strtol+0x2a>
		s++;
  801c7e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c81:	bf 00 00 00 00       	mov    $0x0,%edi
  801c86:	eb 11                	jmp    801c99 <strtol+0x3b>
  801c88:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c8d:	3c 2d                	cmp    $0x2d,%al
  801c8f:	75 08                	jne    801c99 <strtol+0x3b>
		s++, neg = 1;
  801c91:	83 c1 01             	add    $0x1,%ecx
  801c94:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c99:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801c9f:	75 15                	jne    801cb6 <strtol+0x58>
  801ca1:	80 39 30             	cmpb   $0x30,(%ecx)
  801ca4:	75 10                	jne    801cb6 <strtol+0x58>
  801ca6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801caa:	75 7c                	jne    801d28 <strtol+0xca>
		s += 2, base = 16;
  801cac:	83 c1 02             	add    $0x2,%ecx
  801caf:	bb 10 00 00 00       	mov    $0x10,%ebx
  801cb4:	eb 16                	jmp    801ccc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801cb6:	85 db                	test   %ebx,%ebx
  801cb8:	75 12                	jne    801ccc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cba:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cbf:	80 39 30             	cmpb   $0x30,(%ecx)
  801cc2:	75 08                	jne    801ccc <strtol+0x6e>
		s++, base = 8;
  801cc4:	83 c1 01             	add    $0x1,%ecx
  801cc7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801ccc:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cd4:	0f b6 11             	movzbl (%ecx),%edx
  801cd7:	8d 72 d0             	lea    -0x30(%edx),%esi
  801cda:	89 f3                	mov    %esi,%ebx
  801cdc:	80 fb 09             	cmp    $0x9,%bl
  801cdf:	77 08                	ja     801ce9 <strtol+0x8b>
			dig = *s - '0';
  801ce1:	0f be d2             	movsbl %dl,%edx
  801ce4:	83 ea 30             	sub    $0x30,%edx
  801ce7:	eb 22                	jmp    801d0b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ce9:	8d 72 9f             	lea    -0x61(%edx),%esi
  801cec:	89 f3                	mov    %esi,%ebx
  801cee:	80 fb 19             	cmp    $0x19,%bl
  801cf1:	77 08                	ja     801cfb <strtol+0x9d>
			dig = *s - 'a' + 10;
  801cf3:	0f be d2             	movsbl %dl,%edx
  801cf6:	83 ea 57             	sub    $0x57,%edx
  801cf9:	eb 10                	jmp    801d0b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801cfb:	8d 72 bf             	lea    -0x41(%edx),%esi
  801cfe:	89 f3                	mov    %esi,%ebx
  801d00:	80 fb 19             	cmp    $0x19,%bl
  801d03:	77 16                	ja     801d1b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d05:	0f be d2             	movsbl %dl,%edx
  801d08:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d0b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d0e:	7d 0b                	jge    801d1b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d10:	83 c1 01             	add    $0x1,%ecx
  801d13:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d17:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d19:	eb b9                	jmp    801cd4 <strtol+0x76>

	if (endptr)
  801d1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d1f:	74 0d                	je     801d2e <strtol+0xd0>
		*endptr = (char *) s;
  801d21:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d24:	89 0e                	mov    %ecx,(%esi)
  801d26:	eb 06                	jmp    801d2e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d28:	85 db                	test   %ebx,%ebx
  801d2a:	74 98                	je     801cc4 <strtol+0x66>
  801d2c:	eb 9e                	jmp    801ccc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d2e:	89 c2                	mov    %eax,%edx
  801d30:	f7 da                	neg    %edx
  801d32:	85 ff                	test   %edi,%edi
  801d34:	0f 45 c2             	cmovne %edx,%eax
}
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d42:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d49:	75 2a                	jne    801d75 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d4b:	83 ec 04             	sub    $0x4,%esp
  801d4e:	6a 07                	push   $0x7
  801d50:	68 00 f0 bf ee       	push   $0xeebff000
  801d55:	6a 00                	push   $0x0
  801d57:	e8 2e e4 ff ff       	call   80018a <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	85 c0                	test   %eax,%eax
  801d61:	79 12                	jns    801d75 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d63:	50                   	push   %eax
  801d64:	68 80 26 80 00       	push   $0x802680
  801d69:	6a 23                	push   $0x23
  801d6b:	68 84 26 80 00       	push   $0x802684
  801d70:	e8 22 f6 ff ff       	call   801397 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d75:	8b 45 08             	mov    0x8(%ebp),%eax
  801d78:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d7d:	83 ec 08             	sub    $0x8,%esp
  801d80:	68 a7 1d 80 00       	push   $0x801da7
  801d85:	6a 00                	push   $0x0
  801d87:	e8 49 e5 ff ff       	call   8002d5 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	79 12                	jns    801da5 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801d93:	50                   	push   %eax
  801d94:	68 80 26 80 00       	push   $0x802680
  801d99:	6a 2c                	push   $0x2c
  801d9b:	68 84 26 80 00       	push   $0x802684
  801da0:	e8 f2 f5 ff ff       	call   801397 <_panic>
	}
}
  801da5:	c9                   	leave  
  801da6:	c3                   	ret    

00801da7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801da7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801da8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dad:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801daf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801db2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801db6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dbb:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dbf:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dc1:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dc4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dc5:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dc8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dc9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dca:	c3                   	ret    

00801dcb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	56                   	push   %esi
  801dcf:	53                   	push   %ebx
  801dd0:	8b 75 08             	mov    0x8(%ebp),%esi
  801dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	75 12                	jne    801def <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801ddd:	83 ec 0c             	sub    $0xc,%esp
  801de0:	68 00 00 c0 ee       	push   $0xeec00000
  801de5:	e8 50 e5 ff ff       	call   80033a <sys_ipc_recv>
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	eb 0c                	jmp    801dfb <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801def:	83 ec 0c             	sub    $0xc,%esp
  801df2:	50                   	push   %eax
  801df3:	e8 42 e5 ff ff       	call   80033a <sys_ipc_recv>
  801df8:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801dfb:	85 f6                	test   %esi,%esi
  801dfd:	0f 95 c1             	setne  %cl
  801e00:	85 db                	test   %ebx,%ebx
  801e02:	0f 95 c2             	setne  %dl
  801e05:	84 d1                	test   %dl,%cl
  801e07:	74 09                	je     801e12 <ipc_recv+0x47>
  801e09:	89 c2                	mov    %eax,%edx
  801e0b:	c1 ea 1f             	shr    $0x1f,%edx
  801e0e:	84 d2                	test   %dl,%dl
  801e10:	75 2a                	jne    801e3c <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e12:	85 f6                	test   %esi,%esi
  801e14:	74 0d                	je     801e23 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e16:	a1 04 40 80 00       	mov    0x804004,%eax
  801e1b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e21:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e23:	85 db                	test   %ebx,%ebx
  801e25:	74 0d                	je     801e34 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e27:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2c:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e32:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e34:	a1 04 40 80 00       	mov    0x804004,%eax
  801e39:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801e3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3f:	5b                   	pop    %ebx
  801e40:	5e                   	pop    %esi
  801e41:	5d                   	pop    %ebp
  801e42:	c3                   	ret    

00801e43 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	57                   	push   %edi
  801e47:	56                   	push   %esi
  801e48:	53                   	push   %ebx
  801e49:	83 ec 0c             	sub    $0xc,%esp
  801e4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e55:	85 db                	test   %ebx,%ebx
  801e57:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e5c:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e5f:	ff 75 14             	pushl  0x14(%ebp)
  801e62:	53                   	push   %ebx
  801e63:	56                   	push   %esi
  801e64:	57                   	push   %edi
  801e65:	e8 ad e4 ff ff       	call   800317 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e6a:	89 c2                	mov    %eax,%edx
  801e6c:	c1 ea 1f             	shr    $0x1f,%edx
  801e6f:	83 c4 10             	add    $0x10,%esp
  801e72:	84 d2                	test   %dl,%dl
  801e74:	74 17                	je     801e8d <ipc_send+0x4a>
  801e76:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e79:	74 12                	je     801e8d <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e7b:	50                   	push   %eax
  801e7c:	68 92 26 80 00       	push   $0x802692
  801e81:	6a 47                	push   $0x47
  801e83:	68 a0 26 80 00       	push   $0x8026a0
  801e88:	e8 0a f5 ff ff       	call   801397 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e8d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e90:	75 07                	jne    801e99 <ipc_send+0x56>
			sys_yield();
  801e92:	e8 d4 e2 ff ff       	call   80016b <sys_yield>
  801e97:	eb c6                	jmp    801e5f <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	75 c2                	jne    801e5f <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801e9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea0:	5b                   	pop    %ebx
  801ea1:	5e                   	pop    %esi
  801ea2:	5f                   	pop    %edi
  801ea3:	5d                   	pop    %ebp
  801ea4:	c3                   	ret    

00801ea5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eab:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eb0:	89 c2                	mov    %eax,%edx
  801eb2:	c1 e2 07             	shl    $0x7,%edx
  801eb5:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801ebc:	8b 52 5c             	mov    0x5c(%edx),%edx
  801ebf:	39 ca                	cmp    %ecx,%edx
  801ec1:	75 11                	jne    801ed4 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801ec3:	89 c2                	mov    %eax,%edx
  801ec5:	c1 e2 07             	shl    $0x7,%edx
  801ec8:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801ecf:	8b 40 54             	mov    0x54(%eax),%eax
  801ed2:	eb 0f                	jmp    801ee3 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ed4:	83 c0 01             	add    $0x1,%eax
  801ed7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801edc:	75 d2                	jne    801eb0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ede:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ee3:	5d                   	pop    %ebp
  801ee4:	c3                   	ret    

00801ee5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eeb:	89 d0                	mov    %edx,%eax
  801eed:	c1 e8 16             	shr    $0x16,%eax
  801ef0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ef7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801efc:	f6 c1 01             	test   $0x1,%cl
  801eff:	74 1d                	je     801f1e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f01:	c1 ea 0c             	shr    $0xc,%edx
  801f04:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f0b:	f6 c2 01             	test   $0x1,%dl
  801f0e:	74 0e                	je     801f1e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f10:	c1 ea 0c             	shr    $0xc,%edx
  801f13:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f1a:	ef 
  801f1b:	0f b7 c0             	movzwl %ax,%eax
}
  801f1e:	5d                   	pop    %ebp
  801f1f:	c3                   	ret    

00801f20 <__udivdi3>:
  801f20:	55                   	push   %ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 1c             	sub    $0x1c,%esp
  801f27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f37:	85 f6                	test   %esi,%esi
  801f39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f3d:	89 ca                	mov    %ecx,%edx
  801f3f:	89 f8                	mov    %edi,%eax
  801f41:	75 3d                	jne    801f80 <__udivdi3+0x60>
  801f43:	39 cf                	cmp    %ecx,%edi
  801f45:	0f 87 c5 00 00 00    	ja     802010 <__udivdi3+0xf0>
  801f4b:	85 ff                	test   %edi,%edi
  801f4d:	89 fd                	mov    %edi,%ebp
  801f4f:	75 0b                	jne    801f5c <__udivdi3+0x3c>
  801f51:	b8 01 00 00 00       	mov    $0x1,%eax
  801f56:	31 d2                	xor    %edx,%edx
  801f58:	f7 f7                	div    %edi
  801f5a:	89 c5                	mov    %eax,%ebp
  801f5c:	89 c8                	mov    %ecx,%eax
  801f5e:	31 d2                	xor    %edx,%edx
  801f60:	f7 f5                	div    %ebp
  801f62:	89 c1                	mov    %eax,%ecx
  801f64:	89 d8                	mov    %ebx,%eax
  801f66:	89 cf                	mov    %ecx,%edi
  801f68:	f7 f5                	div    %ebp
  801f6a:	89 c3                	mov    %eax,%ebx
  801f6c:	89 d8                	mov    %ebx,%eax
  801f6e:	89 fa                	mov    %edi,%edx
  801f70:	83 c4 1c             	add    $0x1c,%esp
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5f                   	pop    %edi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    
  801f78:	90                   	nop
  801f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f80:	39 ce                	cmp    %ecx,%esi
  801f82:	77 74                	ja     801ff8 <__udivdi3+0xd8>
  801f84:	0f bd fe             	bsr    %esi,%edi
  801f87:	83 f7 1f             	xor    $0x1f,%edi
  801f8a:	0f 84 98 00 00 00    	je     802028 <__udivdi3+0x108>
  801f90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	89 c5                	mov    %eax,%ebp
  801f99:	29 fb                	sub    %edi,%ebx
  801f9b:	d3 e6                	shl    %cl,%esi
  801f9d:	89 d9                	mov    %ebx,%ecx
  801f9f:	d3 ed                	shr    %cl,%ebp
  801fa1:	89 f9                	mov    %edi,%ecx
  801fa3:	d3 e0                	shl    %cl,%eax
  801fa5:	09 ee                	or     %ebp,%esi
  801fa7:	89 d9                	mov    %ebx,%ecx
  801fa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fad:	89 d5                	mov    %edx,%ebp
  801faf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fb3:	d3 ed                	shr    %cl,%ebp
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	d3 e2                	shl    %cl,%edx
  801fb9:	89 d9                	mov    %ebx,%ecx
  801fbb:	d3 e8                	shr    %cl,%eax
  801fbd:	09 c2                	or     %eax,%edx
  801fbf:	89 d0                	mov    %edx,%eax
  801fc1:	89 ea                	mov    %ebp,%edx
  801fc3:	f7 f6                	div    %esi
  801fc5:	89 d5                	mov    %edx,%ebp
  801fc7:	89 c3                	mov    %eax,%ebx
  801fc9:	f7 64 24 0c          	mull   0xc(%esp)
  801fcd:	39 d5                	cmp    %edx,%ebp
  801fcf:	72 10                	jb     801fe1 <__udivdi3+0xc1>
  801fd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e6                	shl    %cl,%esi
  801fd9:	39 c6                	cmp    %eax,%esi
  801fdb:	73 07                	jae    801fe4 <__udivdi3+0xc4>
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	75 03                	jne    801fe4 <__udivdi3+0xc4>
  801fe1:	83 eb 01             	sub    $0x1,%ebx
  801fe4:	31 ff                	xor    %edi,%edi
  801fe6:	89 d8                	mov    %ebx,%eax
  801fe8:	89 fa                	mov    %edi,%edx
  801fea:	83 c4 1c             	add    $0x1c,%esp
  801fed:	5b                   	pop    %ebx
  801fee:	5e                   	pop    %esi
  801fef:	5f                   	pop    %edi
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    
  801ff2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ff8:	31 ff                	xor    %edi,%edi
  801ffa:	31 db                	xor    %ebx,%ebx
  801ffc:	89 d8                	mov    %ebx,%eax
  801ffe:	89 fa                	mov    %edi,%edx
  802000:	83 c4 1c             	add    $0x1c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
  802008:	90                   	nop
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	89 d8                	mov    %ebx,%eax
  802012:	f7 f7                	div    %edi
  802014:	31 ff                	xor    %edi,%edi
  802016:	89 c3                	mov    %eax,%ebx
  802018:	89 d8                	mov    %ebx,%eax
  80201a:	89 fa                	mov    %edi,%edx
  80201c:	83 c4 1c             	add    $0x1c,%esp
  80201f:	5b                   	pop    %ebx
  802020:	5e                   	pop    %esi
  802021:	5f                   	pop    %edi
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    
  802024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802028:	39 ce                	cmp    %ecx,%esi
  80202a:	72 0c                	jb     802038 <__udivdi3+0x118>
  80202c:	31 db                	xor    %ebx,%ebx
  80202e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802032:	0f 87 34 ff ff ff    	ja     801f6c <__udivdi3+0x4c>
  802038:	bb 01 00 00 00       	mov    $0x1,%ebx
  80203d:	e9 2a ff ff ff       	jmp    801f6c <__udivdi3+0x4c>
  802042:	66 90                	xchg   %ax,%ax
  802044:	66 90                	xchg   %ax,%ax
  802046:	66 90                	xchg   %ax,%ax
  802048:	66 90                	xchg   %ax,%ax
  80204a:	66 90                	xchg   %ax,%ax
  80204c:	66 90                	xchg   %ax,%ax
  80204e:	66 90                	xchg   %ax,%ax

00802050 <__umoddi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80205b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80205f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802063:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802067:	85 d2                	test   %edx,%edx
  802069:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80206d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802071:	89 f3                	mov    %esi,%ebx
  802073:	89 3c 24             	mov    %edi,(%esp)
  802076:	89 74 24 04          	mov    %esi,0x4(%esp)
  80207a:	75 1c                	jne    802098 <__umoddi3+0x48>
  80207c:	39 f7                	cmp    %esi,%edi
  80207e:	76 50                	jbe    8020d0 <__umoddi3+0x80>
  802080:	89 c8                	mov    %ecx,%eax
  802082:	89 f2                	mov    %esi,%edx
  802084:	f7 f7                	div    %edi
  802086:	89 d0                	mov    %edx,%eax
  802088:	31 d2                	xor    %edx,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	39 f2                	cmp    %esi,%edx
  80209a:	89 d0                	mov    %edx,%eax
  80209c:	77 52                	ja     8020f0 <__umoddi3+0xa0>
  80209e:	0f bd ea             	bsr    %edx,%ebp
  8020a1:	83 f5 1f             	xor    $0x1f,%ebp
  8020a4:	75 5a                	jne    802100 <__umoddi3+0xb0>
  8020a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020aa:	0f 82 e0 00 00 00    	jb     802190 <__umoddi3+0x140>
  8020b0:	39 0c 24             	cmp    %ecx,(%esp)
  8020b3:	0f 86 d7 00 00 00    	jbe    802190 <__umoddi3+0x140>
  8020b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020c1:	83 c4 1c             	add    $0x1c,%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5f                   	pop    %edi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	85 ff                	test   %edi,%edi
  8020d2:	89 fd                	mov    %edi,%ebp
  8020d4:	75 0b                	jne    8020e1 <__umoddi3+0x91>
  8020d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020db:	31 d2                	xor    %edx,%edx
  8020dd:	f7 f7                	div    %edi
  8020df:	89 c5                	mov    %eax,%ebp
  8020e1:	89 f0                	mov    %esi,%eax
  8020e3:	31 d2                	xor    %edx,%edx
  8020e5:	f7 f5                	div    %ebp
  8020e7:	89 c8                	mov    %ecx,%eax
  8020e9:	f7 f5                	div    %ebp
  8020eb:	89 d0                	mov    %edx,%eax
  8020ed:	eb 99                	jmp    802088 <__umoddi3+0x38>
  8020ef:	90                   	nop
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	83 c4 1c             	add    $0x1c,%esp
  8020f7:	5b                   	pop    %ebx
  8020f8:	5e                   	pop    %esi
  8020f9:	5f                   	pop    %edi
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    
  8020fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802100:	8b 34 24             	mov    (%esp),%esi
  802103:	bf 20 00 00 00       	mov    $0x20,%edi
  802108:	89 e9                	mov    %ebp,%ecx
  80210a:	29 ef                	sub    %ebp,%edi
  80210c:	d3 e0                	shl    %cl,%eax
  80210e:	89 f9                	mov    %edi,%ecx
  802110:	89 f2                	mov    %esi,%edx
  802112:	d3 ea                	shr    %cl,%edx
  802114:	89 e9                	mov    %ebp,%ecx
  802116:	09 c2                	or     %eax,%edx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 14 24             	mov    %edx,(%esp)
  80211d:	89 f2                	mov    %esi,%edx
  80211f:	d3 e2                	shl    %cl,%edx
  802121:	89 f9                	mov    %edi,%ecx
  802123:	89 54 24 04          	mov    %edx,0x4(%esp)
  802127:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	89 e9                	mov    %ebp,%ecx
  80212f:	89 c6                	mov    %eax,%esi
  802131:	d3 e3                	shl    %cl,%ebx
  802133:	89 f9                	mov    %edi,%ecx
  802135:	89 d0                	mov    %edx,%eax
  802137:	d3 e8                	shr    %cl,%eax
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	09 d8                	or     %ebx,%eax
  80213d:	89 d3                	mov    %edx,%ebx
  80213f:	89 f2                	mov    %esi,%edx
  802141:	f7 34 24             	divl   (%esp)
  802144:	89 d6                	mov    %edx,%esi
  802146:	d3 e3                	shl    %cl,%ebx
  802148:	f7 64 24 04          	mull   0x4(%esp)
  80214c:	39 d6                	cmp    %edx,%esi
  80214e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802152:	89 d1                	mov    %edx,%ecx
  802154:	89 c3                	mov    %eax,%ebx
  802156:	72 08                	jb     802160 <__umoddi3+0x110>
  802158:	75 11                	jne    80216b <__umoddi3+0x11b>
  80215a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80215e:	73 0b                	jae    80216b <__umoddi3+0x11b>
  802160:	2b 44 24 04          	sub    0x4(%esp),%eax
  802164:	1b 14 24             	sbb    (%esp),%edx
  802167:	89 d1                	mov    %edx,%ecx
  802169:	89 c3                	mov    %eax,%ebx
  80216b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80216f:	29 da                	sub    %ebx,%edx
  802171:	19 ce                	sbb    %ecx,%esi
  802173:	89 f9                	mov    %edi,%ecx
  802175:	89 f0                	mov    %esi,%eax
  802177:	d3 e0                	shl    %cl,%eax
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	d3 ea                	shr    %cl,%edx
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	d3 ee                	shr    %cl,%esi
  802181:	09 d0                	or     %edx,%eax
  802183:	89 f2                	mov    %esi,%edx
  802185:	83 c4 1c             	add    $0x1c,%esp
  802188:	5b                   	pop    %ebx
  802189:	5e                   	pop    %esi
  80218a:	5f                   	pop    %edi
  80218b:	5d                   	pop    %ebp
  80218c:	c3                   	ret    
  80218d:	8d 76 00             	lea    0x0(%esi),%esi
  802190:	29 f9                	sub    %edi,%ecx
  802192:	19 d6                	sbb    %edx,%esi
  802194:	89 74 24 04          	mov    %esi,0x4(%esp)
  802198:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80219c:	e9 18 ff ff ff       	jmp    8020b9 <__umoddi3+0x69>
