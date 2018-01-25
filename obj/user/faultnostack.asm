
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
  800039:	68 c5 03 80 00       	push   $0x8003c5
  80003e:	6a 00                	push   $0x0
  800040:	e8 9a 02 00 00       	call   8002df <sys_env_set_pgfault_upcall>
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
  80005f:	e8 f2 00 00 00       	call   800156 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	89 c2                	mov    %eax,%edx
  80006b:	c1 e2 07             	shl    $0x7,%edx
  80006e:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800075:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 db                	test   %ebx,%ebx
  80007c:	7e 07                	jle    800085 <libmain+0x31>
		binaryname = argv[0];
  80007e:	8b 06                	mov    (%esi),%eax
  800080:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800085:	83 ec 08             	sub    $0x8,%esp
  800088:	56                   	push   %esi
  800089:	53                   	push   %ebx
  80008a:	e8 a4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008f:	e8 2a 00 00 00       	call   8000be <exit>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5e                   	pop    %esi
  80009c:	5d                   	pop    %ebp
  80009d:	c3                   	ret    

0080009e <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000a4:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000a9:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000ab:	e8 a6 00 00 00       	call   800156 <sys_getenvid>
  8000b0:	83 ec 0c             	sub    $0xc,%esp
  8000b3:	50                   	push   %eax
  8000b4:	e8 ec 02 00 00       	call   8003a5 <sys_thread_free>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c4:	e8 dd 07 00 00       	call   8008a6 <close_all>
	sys_env_destroy(0);
  8000c9:	83 ec 0c             	sub    $0xc,%esp
  8000cc:	6a 00                	push   $0x0
  8000ce:	e8 42 00 00 00       	call   800115 <sys_env_destroy>
}
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	57                   	push   %edi
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000de:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e9:	89 c3                	mov    %eax,%ebx
  8000eb:	89 c7                	mov    %eax,%edi
  8000ed:	89 c6                	mov    %eax,%esi
  8000ef:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f1:	5b                   	pop    %ebx
  8000f2:	5e                   	pop    %esi
  8000f3:	5f                   	pop    %edi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    

008000f6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	57                   	push   %edi
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800101:	b8 01 00 00 00       	mov    $0x1,%eax
  800106:	89 d1                	mov    %edx,%ecx
  800108:	89 d3                	mov    %edx,%ebx
  80010a:	89 d7                	mov    %edx,%edi
  80010c:	89 d6                	mov    %edx,%esi
  80010e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800110:	5b                   	pop    %ebx
  800111:	5e                   	pop    %esi
  800112:	5f                   	pop    %edi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    

00800115 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	57                   	push   %edi
  800119:	56                   	push   %esi
  80011a:	53                   	push   %ebx
  80011b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800123:	b8 03 00 00 00       	mov    $0x3,%eax
  800128:	8b 55 08             	mov    0x8(%ebp),%edx
  80012b:	89 cb                	mov    %ecx,%ebx
  80012d:	89 cf                	mov    %ecx,%edi
  80012f:	89 ce                	mov    %ecx,%esi
  800131:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800133:	85 c0                	test   %eax,%eax
  800135:	7e 17                	jle    80014e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	50                   	push   %eax
  80013b:	6a 03                	push   $0x3
  80013d:	68 ca 21 80 00       	push   $0x8021ca
  800142:	6a 23                	push   $0x23
  800144:	68 e7 21 80 00       	push   $0x8021e7
  800149:	e8 77 12 00 00       	call   8013c5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015c:	ba 00 00 00 00       	mov    $0x0,%edx
  800161:	b8 02 00 00 00       	mov    $0x2,%eax
  800166:	89 d1                	mov    %edx,%ecx
  800168:	89 d3                	mov    %edx,%ebx
  80016a:	89 d7                	mov    %edx,%edi
  80016c:	89 d6                	mov    %edx,%esi
  80016e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800170:	5b                   	pop    %ebx
  800171:	5e                   	pop    %esi
  800172:	5f                   	pop    %edi
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    

00800175 <sys_yield>:

void
sys_yield(void)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	57                   	push   %edi
  800179:	56                   	push   %esi
  80017a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017b:	ba 00 00 00 00       	mov    $0x0,%edx
  800180:	b8 0b 00 00 00       	mov    $0xb,%eax
  800185:	89 d1                	mov    %edx,%ecx
  800187:	89 d3                	mov    %edx,%ebx
  800189:	89 d7                	mov    %edx,%edi
  80018b:	89 d6                	mov    %edx,%esi
  80018d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80018f:	5b                   	pop    %ebx
  800190:	5e                   	pop    %esi
  800191:	5f                   	pop    %edi
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    

00800194 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	57                   	push   %edi
  800198:	56                   	push   %esi
  800199:	53                   	push   %ebx
  80019a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019d:	be 00 00 00 00       	mov    $0x0,%esi
  8001a2:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	89 f7                	mov    %esi,%edi
  8001b2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	7e 17                	jle    8001cf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	50                   	push   %eax
  8001bc:	6a 04                	push   $0x4
  8001be:	68 ca 21 80 00       	push   $0x8021ca
  8001c3:	6a 23                	push   $0x23
  8001c5:	68 e7 21 80 00       	push   $0x8021e7
  8001ca:	e8 f6 11 00 00       	call   8013c5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5e                   	pop    %esi
  8001d4:	5f                   	pop    %edi
  8001d5:	5d                   	pop    %ebp
  8001d6:	c3                   	ret    

008001d7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	57                   	push   %edi
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ee:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7e 17                	jle    800211 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	50                   	push   %eax
  8001fe:	6a 05                	push   $0x5
  800200:	68 ca 21 80 00       	push   $0x8021ca
  800205:	6a 23                	push   $0x23
  800207:	68 e7 21 80 00       	push   $0x8021e7
  80020c:	e8 b4 11 00 00       	call   8013c5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800222:	bb 00 00 00 00       	mov    $0x0,%ebx
  800227:	b8 06 00 00 00       	mov    $0x6,%eax
  80022c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	89 df                	mov    %ebx,%edi
  800234:	89 de                	mov    %ebx,%esi
  800236:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800238:	85 c0                	test   %eax,%eax
  80023a:	7e 17                	jle    800253 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	50                   	push   %eax
  800240:	6a 06                	push   $0x6
  800242:	68 ca 21 80 00       	push   $0x8021ca
  800247:	6a 23                	push   $0x23
  800249:	68 e7 21 80 00       	push   $0x8021e7
  80024e:	e8 72 11 00 00       	call   8013c5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800253:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800256:	5b                   	pop    %ebx
  800257:	5e                   	pop    %esi
  800258:	5f                   	pop    %edi
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	b8 08 00 00 00       	mov    $0x8,%eax
  80026e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	89 df                	mov    %ebx,%edi
  800276:	89 de                	mov    %ebx,%esi
  800278:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027a:	85 c0                	test   %eax,%eax
  80027c:	7e 17                	jle    800295 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	50                   	push   %eax
  800282:	6a 08                	push   $0x8
  800284:	68 ca 21 80 00       	push   $0x8021ca
  800289:	6a 23                	push   $0x23
  80028b:	68 e7 21 80 00       	push   $0x8021e7
  800290:	e8 30 11 00 00       	call   8013c5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800295:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
  8002a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ab:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	89 df                	mov    %ebx,%edi
  8002b8:	89 de                	mov    %ebx,%esi
  8002ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002bc:	85 c0                	test   %eax,%eax
  8002be:	7e 17                	jle    8002d7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c0:	83 ec 0c             	sub    $0xc,%esp
  8002c3:	50                   	push   %eax
  8002c4:	6a 09                	push   $0x9
  8002c6:	68 ca 21 80 00       	push   $0x8021ca
  8002cb:	6a 23                	push   $0x23
  8002cd:	68 e7 21 80 00       	push   $0x8021e7
  8002d2:	e8 ee 10 00 00       	call   8013c5 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002da:	5b                   	pop    %ebx
  8002db:	5e                   	pop    %esi
  8002dc:	5f                   	pop    %edi
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
  8002e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	89 df                	mov    %ebx,%edi
  8002fa:	89 de                	mov    %ebx,%esi
  8002fc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002fe:	85 c0                	test   %eax,%eax
  800300:	7e 17                	jle    800319 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	50                   	push   %eax
  800306:	6a 0a                	push   $0xa
  800308:	68 ca 21 80 00       	push   $0x8021ca
  80030d:	6a 23                	push   $0x23
  80030f:	68 e7 21 80 00       	push   $0x8021e7
  800314:	e8 ac 10 00 00       	call   8013c5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800319:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031c:	5b                   	pop    %ebx
  80031d:	5e                   	pop    %esi
  80031e:	5f                   	pop    %edi
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	57                   	push   %edi
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800327:	be 00 00 00 00       	mov    $0x0,%esi
  80032c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800331:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800334:	8b 55 08             	mov    0x8(%ebp),%edx
  800337:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80033d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80033f:	5b                   	pop    %ebx
  800340:	5e                   	pop    %esi
  800341:	5f                   	pop    %edi
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    

00800344 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800352:	b8 0d 00 00 00       	mov    $0xd,%eax
  800357:	8b 55 08             	mov    0x8(%ebp),%edx
  80035a:	89 cb                	mov    %ecx,%ebx
  80035c:	89 cf                	mov    %ecx,%edi
  80035e:	89 ce                	mov    %ecx,%esi
  800360:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800362:	85 c0                	test   %eax,%eax
  800364:	7e 17                	jle    80037d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800366:	83 ec 0c             	sub    $0xc,%esp
  800369:	50                   	push   %eax
  80036a:	6a 0d                	push   $0xd
  80036c:	68 ca 21 80 00       	push   $0x8021ca
  800371:	6a 23                	push   $0x23
  800373:	68 e7 21 80 00       	push   $0x8021e7
  800378:	e8 48 10 00 00       	call   8013c5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80037d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800380:	5b                   	pop    %ebx
  800381:	5e                   	pop    %esi
  800382:	5f                   	pop    %edi
  800383:	5d                   	pop    %ebp
  800384:	c3                   	ret    

00800385 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800390:	b8 0e 00 00 00       	mov    $0xe,%eax
  800395:	8b 55 08             	mov    0x8(%ebp),%edx
  800398:	89 cb                	mov    %ecx,%ebx
  80039a:	89 cf                	mov    %ecx,%edi
  80039c:	89 ce                	mov    %ecx,%esi
  80039e:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  8003a0:	5b                   	pop    %ebx
  8003a1:	5e                   	pop    %esi
  8003a2:	5f                   	pop    %edi
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	57                   	push   %edi
  8003a9:	56                   	push   %esi
  8003aa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b0:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b8:	89 cb                	mov    %ecx,%ebx
  8003ba:	89 cf                	mov    %ecx,%edi
  8003bc:	89 ce                	mov    %ecx,%esi
  8003be:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003c0:	5b                   	pop    %ebx
  8003c1:	5e                   	pop    %esi
  8003c2:	5f                   	pop    %edi
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003c5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003c6:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8003cb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003cd:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8003d0:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8003d4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8003d9:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8003dd:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8003df:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8003e2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8003e3:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8003e6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8003e7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8003e8:	c3                   	ret    

008003e9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	53                   	push   %ebx
  8003ed:	83 ec 04             	sub    $0x4,%esp
  8003f0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003f3:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003f5:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003f9:	74 11                	je     80040c <pgfault+0x23>
  8003fb:	89 d8                	mov    %ebx,%eax
  8003fd:	c1 e8 0c             	shr    $0xc,%eax
  800400:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800407:	f6 c4 08             	test   $0x8,%ah
  80040a:	75 14                	jne    800420 <pgfault+0x37>
		panic("faulting access");
  80040c:	83 ec 04             	sub    $0x4,%esp
  80040f:	68 f5 21 80 00       	push   $0x8021f5
  800414:	6a 1e                	push   $0x1e
  800416:	68 05 22 80 00       	push   $0x802205
  80041b:	e8 a5 0f 00 00       	call   8013c5 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800420:	83 ec 04             	sub    $0x4,%esp
  800423:	6a 07                	push   $0x7
  800425:	68 00 f0 7f 00       	push   $0x7ff000
  80042a:	6a 00                	push   $0x0
  80042c:	e8 63 fd ff ff       	call   800194 <sys_page_alloc>
	if (r < 0) {
  800431:	83 c4 10             	add    $0x10,%esp
  800434:	85 c0                	test   %eax,%eax
  800436:	79 12                	jns    80044a <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800438:	50                   	push   %eax
  800439:	68 10 22 80 00       	push   $0x802210
  80043e:	6a 2c                	push   $0x2c
  800440:	68 05 22 80 00       	push   $0x802205
  800445:	e8 7b 0f 00 00       	call   8013c5 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80044a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800450:	83 ec 04             	sub    $0x4,%esp
  800453:	68 00 10 00 00       	push   $0x1000
  800458:	53                   	push   %ebx
  800459:	68 00 f0 7f 00       	push   $0x7ff000
  80045e:	e8 ba 17 00 00       	call   801c1d <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800463:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80046a:	53                   	push   %ebx
  80046b:	6a 00                	push   $0x0
  80046d:	68 00 f0 7f 00       	push   $0x7ff000
  800472:	6a 00                	push   $0x0
  800474:	e8 5e fd ff ff       	call   8001d7 <sys_page_map>
	if (r < 0) {
  800479:	83 c4 20             	add    $0x20,%esp
  80047c:	85 c0                	test   %eax,%eax
  80047e:	79 12                	jns    800492 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800480:	50                   	push   %eax
  800481:	68 10 22 80 00       	push   $0x802210
  800486:	6a 33                	push   $0x33
  800488:	68 05 22 80 00       	push   $0x802205
  80048d:	e8 33 0f 00 00       	call   8013c5 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	68 00 f0 7f 00       	push   $0x7ff000
  80049a:	6a 00                	push   $0x0
  80049c:	e8 78 fd ff ff       	call   800219 <sys_page_unmap>
	if (r < 0) {
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	85 c0                	test   %eax,%eax
  8004a6:	79 12                	jns    8004ba <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  8004a8:	50                   	push   %eax
  8004a9:	68 10 22 80 00       	push   $0x802210
  8004ae:	6a 37                	push   $0x37
  8004b0:	68 05 22 80 00       	push   $0x802205
  8004b5:	e8 0b 0f 00 00       	call   8013c5 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8004ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004bd:	c9                   	leave  
  8004be:	c3                   	ret    

008004bf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	57                   	push   %edi
  8004c3:	56                   	push   %esi
  8004c4:	53                   	push   %ebx
  8004c5:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8004c8:	68 e9 03 80 00       	push   $0x8003e9
  8004cd:	e8 98 18 00 00       	call   801d6a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004d2:	b8 07 00 00 00       	mov    $0x7,%eax
  8004d7:	cd 30                	int    $0x30
  8004d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004dc:	83 c4 10             	add    $0x10,%esp
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	79 17                	jns    8004fa <fork+0x3b>
		panic("fork fault %e");
  8004e3:	83 ec 04             	sub    $0x4,%esp
  8004e6:	68 29 22 80 00       	push   $0x802229
  8004eb:	68 84 00 00 00       	push   $0x84
  8004f0:	68 05 22 80 00       	push   $0x802205
  8004f5:	e8 cb 0e 00 00       	call   8013c5 <_panic>
  8004fa:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800500:	75 25                	jne    800527 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  800502:	e8 4f fc ff ff       	call   800156 <sys_getenvid>
  800507:	25 ff 03 00 00       	and    $0x3ff,%eax
  80050c:	89 c2                	mov    %eax,%edx
  80050e:	c1 e2 07             	shl    $0x7,%edx
  800511:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800518:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80051d:	b8 00 00 00 00       	mov    $0x0,%eax
  800522:	e9 61 01 00 00       	jmp    800688 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800527:	83 ec 04             	sub    $0x4,%esp
  80052a:	6a 07                	push   $0x7
  80052c:	68 00 f0 bf ee       	push   $0xeebff000
  800531:	ff 75 e4             	pushl  -0x1c(%ebp)
  800534:	e8 5b fc ff ff       	call   800194 <sys_page_alloc>
  800539:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80053c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800541:	89 d8                	mov    %ebx,%eax
  800543:	c1 e8 16             	shr    $0x16,%eax
  800546:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80054d:	a8 01                	test   $0x1,%al
  80054f:	0f 84 fc 00 00 00    	je     800651 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800555:	89 d8                	mov    %ebx,%eax
  800557:	c1 e8 0c             	shr    $0xc,%eax
  80055a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800561:	f6 c2 01             	test   $0x1,%dl
  800564:	0f 84 e7 00 00 00    	je     800651 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80056a:	89 c6                	mov    %eax,%esi
  80056c:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80056f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800576:	f6 c6 04             	test   $0x4,%dh
  800579:	74 39                	je     8005b4 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80057b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800582:	83 ec 0c             	sub    $0xc,%esp
  800585:	25 07 0e 00 00       	and    $0xe07,%eax
  80058a:	50                   	push   %eax
  80058b:	56                   	push   %esi
  80058c:	57                   	push   %edi
  80058d:	56                   	push   %esi
  80058e:	6a 00                	push   $0x0
  800590:	e8 42 fc ff ff       	call   8001d7 <sys_page_map>
		if (r < 0) {
  800595:	83 c4 20             	add    $0x20,%esp
  800598:	85 c0                	test   %eax,%eax
  80059a:	0f 89 b1 00 00 00    	jns    800651 <fork+0x192>
		    	panic("sys page map fault %e");
  8005a0:	83 ec 04             	sub    $0x4,%esp
  8005a3:	68 37 22 80 00       	push   $0x802237
  8005a8:	6a 54                	push   $0x54
  8005aa:	68 05 22 80 00       	push   $0x802205
  8005af:	e8 11 0e 00 00       	call   8013c5 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8005b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005bb:	f6 c2 02             	test   $0x2,%dl
  8005be:	75 0c                	jne    8005cc <fork+0x10d>
  8005c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c7:	f6 c4 08             	test   $0x8,%ah
  8005ca:	74 5b                	je     800627 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005cc:	83 ec 0c             	sub    $0xc,%esp
  8005cf:	68 05 08 00 00       	push   $0x805
  8005d4:	56                   	push   %esi
  8005d5:	57                   	push   %edi
  8005d6:	56                   	push   %esi
  8005d7:	6a 00                	push   $0x0
  8005d9:	e8 f9 fb ff ff       	call   8001d7 <sys_page_map>
		if (r < 0) {
  8005de:	83 c4 20             	add    $0x20,%esp
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	79 14                	jns    8005f9 <fork+0x13a>
		    	panic("sys page map fault %e");
  8005e5:	83 ec 04             	sub    $0x4,%esp
  8005e8:	68 37 22 80 00       	push   $0x802237
  8005ed:	6a 5b                	push   $0x5b
  8005ef:	68 05 22 80 00       	push   $0x802205
  8005f4:	e8 cc 0d 00 00       	call   8013c5 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005f9:	83 ec 0c             	sub    $0xc,%esp
  8005fc:	68 05 08 00 00       	push   $0x805
  800601:	56                   	push   %esi
  800602:	6a 00                	push   $0x0
  800604:	56                   	push   %esi
  800605:	6a 00                	push   $0x0
  800607:	e8 cb fb ff ff       	call   8001d7 <sys_page_map>
		if (r < 0) {
  80060c:	83 c4 20             	add    $0x20,%esp
  80060f:	85 c0                	test   %eax,%eax
  800611:	79 3e                	jns    800651 <fork+0x192>
		    	panic("sys page map fault %e");
  800613:	83 ec 04             	sub    $0x4,%esp
  800616:	68 37 22 80 00       	push   $0x802237
  80061b:	6a 5f                	push   $0x5f
  80061d:	68 05 22 80 00       	push   $0x802205
  800622:	e8 9e 0d 00 00       	call   8013c5 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800627:	83 ec 0c             	sub    $0xc,%esp
  80062a:	6a 05                	push   $0x5
  80062c:	56                   	push   %esi
  80062d:	57                   	push   %edi
  80062e:	56                   	push   %esi
  80062f:	6a 00                	push   $0x0
  800631:	e8 a1 fb ff ff       	call   8001d7 <sys_page_map>
		if (r < 0) {
  800636:	83 c4 20             	add    $0x20,%esp
  800639:	85 c0                	test   %eax,%eax
  80063b:	79 14                	jns    800651 <fork+0x192>
		    	panic("sys page map fault %e");
  80063d:	83 ec 04             	sub    $0x4,%esp
  800640:	68 37 22 80 00       	push   $0x802237
  800645:	6a 64                	push   $0x64
  800647:	68 05 22 80 00       	push   $0x802205
  80064c:	e8 74 0d 00 00       	call   8013c5 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800651:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800657:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80065d:	0f 85 de fe ff ff    	jne    800541 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800663:	a1 04 40 80 00       	mov    0x804004,%eax
  800668:	8b 40 70             	mov    0x70(%eax),%eax
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	50                   	push   %eax
  80066f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800672:	57                   	push   %edi
  800673:	e8 67 fc ff ff       	call   8002df <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800678:	83 c4 08             	add    $0x8,%esp
  80067b:	6a 02                	push   $0x2
  80067d:	57                   	push   %edi
  80067e:	e8 d8 fb ff ff       	call   80025b <sys_env_set_status>
	
	return envid;
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800688:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80068b:	5b                   	pop    %ebx
  80068c:	5e                   	pop    %esi
  80068d:	5f                   	pop    %edi
  80068e:	5d                   	pop    %ebp
  80068f:	c3                   	ret    

00800690 <sfork>:

envid_t
sfork(void)
{
  800690:	55                   	push   %ebp
  800691:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800693:	b8 00 00 00 00       	mov    $0x0,%eax
  800698:	5d                   	pop    %ebp
  800699:	c3                   	ret    

0080069a <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	56                   	push   %esi
  80069e:	53                   	push   %ebx
  80069f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8006a2:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	68 50 22 80 00       	push   $0x802250
  8006b1:	e8 e8 0d 00 00       	call   80149e <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006b6:	c7 04 24 9e 00 80 00 	movl   $0x80009e,(%esp)
  8006bd:	e8 c3 fc ff ff       	call   800385 <sys_thread_create>
  8006c2:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006c4:	83 c4 08             	add    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	68 50 22 80 00       	push   $0x802250
  8006cd:	e8 cc 0d 00 00       	call   80149e <cprintf>
	return id;
	//return 0;
}
  8006d2:	89 f0                	mov    %esi,%eax
  8006d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006d7:	5b                   	pop    %ebx
  8006d8:	5e                   	pop    %esi
  8006d9:	5d                   	pop    %ebp
  8006da:	c3                   	ret    

008006db <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006de:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e1:	05 00 00 00 30       	add    $0x30000000,%eax
  8006e6:	c1 e8 0c             	shr    $0xc,%eax
}
  8006e9:	5d                   	pop    %ebp
  8006ea:	c3                   	ret    

008006eb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f1:	05 00 00 00 30       	add    $0x30000000,%eax
  8006f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006fb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800708:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80070d:	89 c2                	mov    %eax,%edx
  80070f:	c1 ea 16             	shr    $0x16,%edx
  800712:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800719:	f6 c2 01             	test   $0x1,%dl
  80071c:	74 11                	je     80072f <fd_alloc+0x2d>
  80071e:	89 c2                	mov    %eax,%edx
  800720:	c1 ea 0c             	shr    $0xc,%edx
  800723:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80072a:	f6 c2 01             	test   $0x1,%dl
  80072d:	75 09                	jne    800738 <fd_alloc+0x36>
			*fd_store = fd;
  80072f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800731:	b8 00 00 00 00       	mov    $0x0,%eax
  800736:	eb 17                	jmp    80074f <fd_alloc+0x4d>
  800738:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80073d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800742:	75 c9                	jne    80070d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800744:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80074a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800757:	83 f8 1f             	cmp    $0x1f,%eax
  80075a:	77 36                	ja     800792 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80075c:	c1 e0 0c             	shl    $0xc,%eax
  80075f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800764:	89 c2                	mov    %eax,%edx
  800766:	c1 ea 16             	shr    $0x16,%edx
  800769:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800770:	f6 c2 01             	test   $0x1,%dl
  800773:	74 24                	je     800799 <fd_lookup+0x48>
  800775:	89 c2                	mov    %eax,%edx
  800777:	c1 ea 0c             	shr    $0xc,%edx
  80077a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800781:	f6 c2 01             	test   $0x1,%dl
  800784:	74 1a                	je     8007a0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800786:	8b 55 0c             	mov    0xc(%ebp),%edx
  800789:	89 02                	mov    %eax,(%edx)
	return 0;
  80078b:	b8 00 00 00 00       	mov    $0x0,%eax
  800790:	eb 13                	jmp    8007a5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800792:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800797:	eb 0c                	jmp    8007a5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800799:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079e:	eb 05                	jmp    8007a5 <fd_lookup+0x54>
  8007a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b0:	ba f0 22 80 00       	mov    $0x8022f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8007b5:	eb 13                	jmp    8007ca <dev_lookup+0x23>
  8007b7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8007ba:	39 08                	cmp    %ecx,(%eax)
  8007bc:	75 0c                	jne    8007ca <dev_lookup+0x23>
			*dev = devtab[i];
  8007be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c8:	eb 2e                	jmp    8007f8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007ca:	8b 02                	mov    (%edx),%eax
  8007cc:	85 c0                	test   %eax,%eax
  8007ce:	75 e7                	jne    8007b7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8007d5:	8b 40 54             	mov    0x54(%eax),%eax
  8007d8:	83 ec 04             	sub    $0x4,%esp
  8007db:	51                   	push   %ecx
  8007dc:	50                   	push   %eax
  8007dd:	68 74 22 80 00       	push   $0x802274
  8007e2:	e8 b7 0c 00 00       	call   80149e <cprintf>
	*dev = 0;
  8007e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	83 ec 10             	sub    $0x10,%esp
  800802:	8b 75 08             	mov    0x8(%ebp),%esi
  800805:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800808:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80080b:	50                   	push   %eax
  80080c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800812:	c1 e8 0c             	shr    $0xc,%eax
  800815:	50                   	push   %eax
  800816:	e8 36 ff ff ff       	call   800751 <fd_lookup>
  80081b:	83 c4 08             	add    $0x8,%esp
  80081e:	85 c0                	test   %eax,%eax
  800820:	78 05                	js     800827 <fd_close+0x2d>
	    || fd != fd2)
  800822:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800825:	74 0c                	je     800833 <fd_close+0x39>
		return (must_exist ? r : 0);
  800827:	84 db                	test   %bl,%bl
  800829:	ba 00 00 00 00       	mov    $0x0,%edx
  80082e:	0f 44 c2             	cmove  %edx,%eax
  800831:	eb 41                	jmp    800874 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800833:	83 ec 08             	sub    $0x8,%esp
  800836:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800839:	50                   	push   %eax
  80083a:	ff 36                	pushl  (%esi)
  80083c:	e8 66 ff ff ff       	call   8007a7 <dev_lookup>
  800841:	89 c3                	mov    %eax,%ebx
  800843:	83 c4 10             	add    $0x10,%esp
  800846:	85 c0                	test   %eax,%eax
  800848:	78 1a                	js     800864 <fd_close+0x6a>
		if (dev->dev_close)
  80084a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800850:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800855:	85 c0                	test   %eax,%eax
  800857:	74 0b                	je     800864 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800859:	83 ec 0c             	sub    $0xc,%esp
  80085c:	56                   	push   %esi
  80085d:	ff d0                	call   *%eax
  80085f:	89 c3                	mov    %eax,%ebx
  800861:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800864:	83 ec 08             	sub    $0x8,%esp
  800867:	56                   	push   %esi
  800868:	6a 00                	push   $0x0
  80086a:	e8 aa f9 ff ff       	call   800219 <sys_page_unmap>
	return r;
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	89 d8                	mov    %ebx,%eax
}
  800874:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800881:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800884:	50                   	push   %eax
  800885:	ff 75 08             	pushl  0x8(%ebp)
  800888:	e8 c4 fe ff ff       	call   800751 <fd_lookup>
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	85 c0                	test   %eax,%eax
  800892:	78 10                	js     8008a4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800894:	83 ec 08             	sub    $0x8,%esp
  800897:	6a 01                	push   $0x1
  800899:	ff 75 f4             	pushl  -0xc(%ebp)
  80089c:	e8 59 ff ff ff       	call   8007fa <fd_close>
  8008a1:	83 c4 10             	add    $0x10,%esp
}
  8008a4:	c9                   	leave  
  8008a5:	c3                   	ret    

008008a6 <close_all>:

void
close_all(void)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	53                   	push   %ebx
  8008aa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8008ad:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8008b2:	83 ec 0c             	sub    $0xc,%esp
  8008b5:	53                   	push   %ebx
  8008b6:	e8 c0 ff ff ff       	call   80087b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8008bb:	83 c3 01             	add    $0x1,%ebx
  8008be:	83 c4 10             	add    $0x10,%esp
  8008c1:	83 fb 20             	cmp    $0x20,%ebx
  8008c4:	75 ec                	jne    8008b2 <close_all+0xc>
		close(i);
}
  8008c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c9:	c9                   	leave  
  8008ca:	c3                   	ret    

008008cb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	57                   	push   %edi
  8008cf:	56                   	push   %esi
  8008d0:	53                   	push   %ebx
  8008d1:	83 ec 2c             	sub    $0x2c,%esp
  8008d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008da:	50                   	push   %eax
  8008db:	ff 75 08             	pushl  0x8(%ebp)
  8008de:	e8 6e fe ff ff       	call   800751 <fd_lookup>
  8008e3:	83 c4 08             	add    $0x8,%esp
  8008e6:	85 c0                	test   %eax,%eax
  8008e8:	0f 88 c1 00 00 00    	js     8009af <dup+0xe4>
		return r;
	close(newfdnum);
  8008ee:	83 ec 0c             	sub    $0xc,%esp
  8008f1:	56                   	push   %esi
  8008f2:	e8 84 ff ff ff       	call   80087b <close>

	newfd = INDEX2FD(newfdnum);
  8008f7:	89 f3                	mov    %esi,%ebx
  8008f9:	c1 e3 0c             	shl    $0xc,%ebx
  8008fc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800902:	83 c4 04             	add    $0x4,%esp
  800905:	ff 75 e4             	pushl  -0x1c(%ebp)
  800908:	e8 de fd ff ff       	call   8006eb <fd2data>
  80090d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80090f:	89 1c 24             	mov    %ebx,(%esp)
  800912:	e8 d4 fd ff ff       	call   8006eb <fd2data>
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80091d:	89 f8                	mov    %edi,%eax
  80091f:	c1 e8 16             	shr    $0x16,%eax
  800922:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800929:	a8 01                	test   $0x1,%al
  80092b:	74 37                	je     800964 <dup+0x99>
  80092d:	89 f8                	mov    %edi,%eax
  80092f:	c1 e8 0c             	shr    $0xc,%eax
  800932:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800939:	f6 c2 01             	test   $0x1,%dl
  80093c:	74 26                	je     800964 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80093e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800945:	83 ec 0c             	sub    $0xc,%esp
  800948:	25 07 0e 00 00       	and    $0xe07,%eax
  80094d:	50                   	push   %eax
  80094e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800951:	6a 00                	push   $0x0
  800953:	57                   	push   %edi
  800954:	6a 00                	push   $0x0
  800956:	e8 7c f8 ff ff       	call   8001d7 <sys_page_map>
  80095b:	89 c7                	mov    %eax,%edi
  80095d:	83 c4 20             	add    $0x20,%esp
  800960:	85 c0                	test   %eax,%eax
  800962:	78 2e                	js     800992 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800964:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800967:	89 d0                	mov    %edx,%eax
  800969:	c1 e8 0c             	shr    $0xc,%eax
  80096c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800973:	83 ec 0c             	sub    $0xc,%esp
  800976:	25 07 0e 00 00       	and    $0xe07,%eax
  80097b:	50                   	push   %eax
  80097c:	53                   	push   %ebx
  80097d:	6a 00                	push   $0x0
  80097f:	52                   	push   %edx
  800980:	6a 00                	push   $0x0
  800982:	e8 50 f8 ff ff       	call   8001d7 <sys_page_map>
  800987:	89 c7                	mov    %eax,%edi
  800989:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80098c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80098e:	85 ff                	test   %edi,%edi
  800990:	79 1d                	jns    8009af <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800992:	83 ec 08             	sub    $0x8,%esp
  800995:	53                   	push   %ebx
  800996:	6a 00                	push   $0x0
  800998:	e8 7c f8 ff ff       	call   800219 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80099d:	83 c4 08             	add    $0x8,%esp
  8009a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009a3:	6a 00                	push   $0x0
  8009a5:	e8 6f f8 ff ff       	call   800219 <sys_page_unmap>
	return r;
  8009aa:	83 c4 10             	add    $0x10,%esp
  8009ad:	89 f8                	mov    %edi,%eax
}
  8009af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b2:	5b                   	pop    %ebx
  8009b3:	5e                   	pop    %esi
  8009b4:	5f                   	pop    %edi
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	53                   	push   %ebx
  8009bb:	83 ec 14             	sub    $0x14,%esp
  8009be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009c4:	50                   	push   %eax
  8009c5:	53                   	push   %ebx
  8009c6:	e8 86 fd ff ff       	call   800751 <fd_lookup>
  8009cb:	83 c4 08             	add    $0x8,%esp
  8009ce:	89 c2                	mov    %eax,%edx
  8009d0:	85 c0                	test   %eax,%eax
  8009d2:	78 6d                	js     800a41 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009d4:	83 ec 08             	sub    $0x8,%esp
  8009d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009da:	50                   	push   %eax
  8009db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009de:	ff 30                	pushl  (%eax)
  8009e0:	e8 c2 fd ff ff       	call   8007a7 <dev_lookup>
  8009e5:	83 c4 10             	add    $0x10,%esp
  8009e8:	85 c0                	test   %eax,%eax
  8009ea:	78 4c                	js     800a38 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009ef:	8b 42 08             	mov    0x8(%edx),%eax
  8009f2:	83 e0 03             	and    $0x3,%eax
  8009f5:	83 f8 01             	cmp    $0x1,%eax
  8009f8:	75 21                	jne    800a1b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8009ff:	8b 40 54             	mov    0x54(%eax),%eax
  800a02:	83 ec 04             	sub    $0x4,%esp
  800a05:	53                   	push   %ebx
  800a06:	50                   	push   %eax
  800a07:	68 b5 22 80 00       	push   $0x8022b5
  800a0c:	e8 8d 0a 00 00       	call   80149e <cprintf>
		return -E_INVAL;
  800a11:	83 c4 10             	add    $0x10,%esp
  800a14:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800a19:	eb 26                	jmp    800a41 <read+0x8a>
	}
	if (!dev->dev_read)
  800a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a1e:	8b 40 08             	mov    0x8(%eax),%eax
  800a21:	85 c0                	test   %eax,%eax
  800a23:	74 17                	je     800a3c <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800a25:	83 ec 04             	sub    $0x4,%esp
  800a28:	ff 75 10             	pushl  0x10(%ebp)
  800a2b:	ff 75 0c             	pushl  0xc(%ebp)
  800a2e:	52                   	push   %edx
  800a2f:	ff d0                	call   *%eax
  800a31:	89 c2                	mov    %eax,%edx
  800a33:	83 c4 10             	add    $0x10,%esp
  800a36:	eb 09                	jmp    800a41 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a38:	89 c2                	mov    %eax,%edx
  800a3a:	eb 05                	jmp    800a41 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a3c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a41:	89 d0                	mov    %edx,%eax
  800a43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a46:	c9                   	leave  
  800a47:	c3                   	ret    

00800a48 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	57                   	push   %edi
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
  800a4e:	83 ec 0c             	sub    $0xc,%esp
  800a51:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a54:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a5c:	eb 21                	jmp    800a7f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a5e:	83 ec 04             	sub    $0x4,%esp
  800a61:	89 f0                	mov    %esi,%eax
  800a63:	29 d8                	sub    %ebx,%eax
  800a65:	50                   	push   %eax
  800a66:	89 d8                	mov    %ebx,%eax
  800a68:	03 45 0c             	add    0xc(%ebp),%eax
  800a6b:	50                   	push   %eax
  800a6c:	57                   	push   %edi
  800a6d:	e8 45 ff ff ff       	call   8009b7 <read>
		if (m < 0)
  800a72:	83 c4 10             	add    $0x10,%esp
  800a75:	85 c0                	test   %eax,%eax
  800a77:	78 10                	js     800a89 <readn+0x41>
			return m;
		if (m == 0)
  800a79:	85 c0                	test   %eax,%eax
  800a7b:	74 0a                	je     800a87 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a7d:	01 c3                	add    %eax,%ebx
  800a7f:	39 f3                	cmp    %esi,%ebx
  800a81:	72 db                	jb     800a5e <readn+0x16>
  800a83:	89 d8                	mov    %ebx,%eax
  800a85:	eb 02                	jmp    800a89 <readn+0x41>
  800a87:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	53                   	push   %ebx
  800a95:	83 ec 14             	sub    $0x14,%esp
  800a98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a9e:	50                   	push   %eax
  800a9f:	53                   	push   %ebx
  800aa0:	e8 ac fc ff ff       	call   800751 <fd_lookup>
  800aa5:	83 c4 08             	add    $0x8,%esp
  800aa8:	89 c2                	mov    %eax,%edx
  800aaa:	85 c0                	test   %eax,%eax
  800aac:	78 68                	js     800b16 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800aae:	83 ec 08             	sub    $0x8,%esp
  800ab1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab4:	50                   	push   %eax
  800ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ab8:	ff 30                	pushl  (%eax)
  800aba:	e8 e8 fc ff ff       	call   8007a7 <dev_lookup>
  800abf:	83 c4 10             	add    $0x10,%esp
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	78 47                	js     800b0d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ac6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800acd:	75 21                	jne    800af0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800acf:	a1 04 40 80 00       	mov    0x804004,%eax
  800ad4:	8b 40 54             	mov    0x54(%eax),%eax
  800ad7:	83 ec 04             	sub    $0x4,%esp
  800ada:	53                   	push   %ebx
  800adb:	50                   	push   %eax
  800adc:	68 d1 22 80 00       	push   $0x8022d1
  800ae1:	e8 b8 09 00 00       	call   80149e <cprintf>
		return -E_INVAL;
  800ae6:	83 c4 10             	add    $0x10,%esp
  800ae9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800aee:	eb 26                	jmp    800b16 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800af0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af3:	8b 52 0c             	mov    0xc(%edx),%edx
  800af6:	85 d2                	test   %edx,%edx
  800af8:	74 17                	je     800b11 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800afa:	83 ec 04             	sub    $0x4,%esp
  800afd:	ff 75 10             	pushl  0x10(%ebp)
  800b00:	ff 75 0c             	pushl  0xc(%ebp)
  800b03:	50                   	push   %eax
  800b04:	ff d2                	call   *%edx
  800b06:	89 c2                	mov    %eax,%edx
  800b08:	83 c4 10             	add    $0x10,%esp
  800b0b:	eb 09                	jmp    800b16 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b0d:	89 c2                	mov    %eax,%edx
  800b0f:	eb 05                	jmp    800b16 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800b11:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800b16:	89 d0                	mov    %edx,%eax
  800b18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b1b:	c9                   	leave  
  800b1c:	c3                   	ret    

00800b1d <seek>:

int
seek(int fdnum, off_t offset)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b23:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b26:	50                   	push   %eax
  800b27:	ff 75 08             	pushl  0x8(%ebp)
  800b2a:	e8 22 fc ff ff       	call   800751 <fd_lookup>
  800b2f:	83 c4 08             	add    $0x8,%esp
  800b32:	85 c0                	test   %eax,%eax
  800b34:	78 0e                	js     800b44 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b36:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b44:	c9                   	leave  
  800b45:	c3                   	ret    

00800b46 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 14             	sub    $0x14,%esp
  800b4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b50:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b53:	50                   	push   %eax
  800b54:	53                   	push   %ebx
  800b55:	e8 f7 fb ff ff       	call   800751 <fd_lookup>
  800b5a:	83 c4 08             	add    $0x8,%esp
  800b5d:	89 c2                	mov    %eax,%edx
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	78 65                	js     800bc8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b63:	83 ec 08             	sub    $0x8,%esp
  800b66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b69:	50                   	push   %eax
  800b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b6d:	ff 30                	pushl  (%eax)
  800b6f:	e8 33 fc ff ff       	call   8007a7 <dev_lookup>
  800b74:	83 c4 10             	add    $0x10,%esp
  800b77:	85 c0                	test   %eax,%eax
  800b79:	78 44                	js     800bbf <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b7e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b82:	75 21                	jne    800ba5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b84:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b89:	8b 40 54             	mov    0x54(%eax),%eax
  800b8c:	83 ec 04             	sub    $0x4,%esp
  800b8f:	53                   	push   %ebx
  800b90:	50                   	push   %eax
  800b91:	68 94 22 80 00       	push   $0x802294
  800b96:	e8 03 09 00 00       	call   80149e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b9b:	83 c4 10             	add    $0x10,%esp
  800b9e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ba3:	eb 23                	jmp    800bc8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800ba5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ba8:	8b 52 18             	mov    0x18(%edx),%edx
  800bab:	85 d2                	test   %edx,%edx
  800bad:	74 14                	je     800bc3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800baf:	83 ec 08             	sub    $0x8,%esp
  800bb2:	ff 75 0c             	pushl  0xc(%ebp)
  800bb5:	50                   	push   %eax
  800bb6:	ff d2                	call   *%edx
  800bb8:	89 c2                	mov    %eax,%edx
  800bba:	83 c4 10             	add    $0x10,%esp
  800bbd:	eb 09                	jmp    800bc8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bbf:	89 c2                	mov    %eax,%edx
  800bc1:	eb 05                	jmp    800bc8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800bc3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800bc8:	89 d0                	mov    %edx,%eax
  800bca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcd:	c9                   	leave  
  800bce:	c3                   	ret    

00800bcf <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 14             	sub    $0x14,%esp
  800bd6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bd9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bdc:	50                   	push   %eax
  800bdd:	ff 75 08             	pushl  0x8(%ebp)
  800be0:	e8 6c fb ff ff       	call   800751 <fd_lookup>
  800be5:	83 c4 08             	add    $0x8,%esp
  800be8:	89 c2                	mov    %eax,%edx
  800bea:	85 c0                	test   %eax,%eax
  800bec:	78 58                	js     800c46 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bee:	83 ec 08             	sub    $0x8,%esp
  800bf1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bf4:	50                   	push   %eax
  800bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bf8:	ff 30                	pushl  (%eax)
  800bfa:	e8 a8 fb ff ff       	call   8007a7 <dev_lookup>
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	85 c0                	test   %eax,%eax
  800c04:	78 37                	js     800c3d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c09:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c0d:	74 32                	je     800c41 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c0f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c12:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c19:	00 00 00 
	stat->st_isdir = 0;
  800c1c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c23:	00 00 00 
	stat->st_dev = dev;
  800c26:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c2c:	83 ec 08             	sub    $0x8,%esp
  800c2f:	53                   	push   %ebx
  800c30:	ff 75 f0             	pushl  -0x10(%ebp)
  800c33:	ff 50 14             	call   *0x14(%eax)
  800c36:	89 c2                	mov    %eax,%edx
  800c38:	83 c4 10             	add    $0x10,%esp
  800c3b:	eb 09                	jmp    800c46 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c3d:	89 c2                	mov    %eax,%edx
  800c3f:	eb 05                	jmp    800c46 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c41:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c46:	89 d0                	mov    %edx,%eax
  800c48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    

00800c4d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c52:	83 ec 08             	sub    $0x8,%esp
  800c55:	6a 00                	push   $0x0
  800c57:	ff 75 08             	pushl  0x8(%ebp)
  800c5a:	e8 e3 01 00 00       	call   800e42 <open>
  800c5f:	89 c3                	mov    %eax,%ebx
  800c61:	83 c4 10             	add    $0x10,%esp
  800c64:	85 c0                	test   %eax,%eax
  800c66:	78 1b                	js     800c83 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c68:	83 ec 08             	sub    $0x8,%esp
  800c6b:	ff 75 0c             	pushl  0xc(%ebp)
  800c6e:	50                   	push   %eax
  800c6f:	e8 5b ff ff ff       	call   800bcf <fstat>
  800c74:	89 c6                	mov    %eax,%esi
	close(fd);
  800c76:	89 1c 24             	mov    %ebx,(%esp)
  800c79:	e8 fd fb ff ff       	call   80087b <close>
	return r;
  800c7e:	83 c4 10             	add    $0x10,%esp
  800c81:	89 f0                	mov    %esi,%eax
}
  800c83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	89 c6                	mov    %eax,%esi
  800c91:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c93:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c9a:	75 12                	jne    800cae <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c9c:	83 ec 0c             	sub    $0xc,%esp
  800c9f:	6a 01                	push   $0x1
  800ca1:	e8 09 12 00 00       	call   801eaf <ipc_find_env>
  800ca6:	a3 00 40 80 00       	mov    %eax,0x804000
  800cab:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800cae:	6a 07                	push   $0x7
  800cb0:	68 00 50 80 00       	push   $0x805000
  800cb5:	56                   	push   %esi
  800cb6:	ff 35 00 40 80 00    	pushl  0x804000
  800cbc:	e8 8c 11 00 00       	call   801e4d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800cc1:	83 c4 0c             	add    $0xc,%esp
  800cc4:	6a 00                	push   $0x0
  800cc6:	53                   	push   %ebx
  800cc7:	6a 00                	push   $0x0
  800cc9:	e8 07 11 00 00       	call   801dd5 <ipc_recv>
}
  800cce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	8b 40 0c             	mov    0xc(%eax),%eax
  800ce1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cee:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf3:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf8:	e8 8d ff ff ff       	call   800c8a <fsipc>
}
  800cfd:	c9                   	leave  
  800cfe:	c3                   	ret    

00800cff <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d05:	8b 45 08             	mov    0x8(%ebp),%eax
  800d08:	8b 40 0c             	mov    0xc(%eax),%eax
  800d0b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d10:	ba 00 00 00 00       	mov    $0x0,%edx
  800d15:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1a:	e8 6b ff ff ff       	call   800c8a <fsipc>
}
  800d1f:	c9                   	leave  
  800d20:	c3                   	ret    

00800d21 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	53                   	push   %ebx
  800d25:	83 ec 04             	sub    $0x4,%esp
  800d28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2e:	8b 40 0c             	mov    0xc(%eax),%eax
  800d31:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d36:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3b:	b8 05 00 00 00       	mov    $0x5,%eax
  800d40:	e8 45 ff ff ff       	call   800c8a <fsipc>
  800d45:	85 c0                	test   %eax,%eax
  800d47:	78 2c                	js     800d75 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d49:	83 ec 08             	sub    $0x8,%esp
  800d4c:	68 00 50 80 00       	push   $0x805000
  800d51:	53                   	push   %ebx
  800d52:	e8 cc 0c 00 00       	call   801a23 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d57:	a1 80 50 80 00       	mov    0x805080,%eax
  800d5c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d62:	a1 84 50 80 00       	mov    0x805084,%eax
  800d67:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d6d:	83 c4 10             	add    $0x10,%esp
  800d70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d78:	c9                   	leave  
  800d79:	c3                   	ret    

00800d7a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	83 ec 0c             	sub    $0xc,%esp
  800d80:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	8b 52 0c             	mov    0xc(%edx),%edx
  800d89:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d8f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d94:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d99:	0f 47 c2             	cmova  %edx,%eax
  800d9c:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800da1:	50                   	push   %eax
  800da2:	ff 75 0c             	pushl  0xc(%ebp)
  800da5:	68 08 50 80 00       	push   $0x805008
  800daa:	e8 06 0e 00 00       	call   801bb5 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800daf:	ba 00 00 00 00       	mov    $0x0,%edx
  800db4:	b8 04 00 00 00       	mov    $0x4,%eax
  800db9:	e8 cc fe ff ff       	call   800c8a <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800dbe:	c9                   	leave  
  800dbf:	c3                   	ret    

00800dc0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcb:	8b 40 0c             	mov    0xc(%eax),%eax
  800dce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800dd3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800dd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dde:	b8 03 00 00 00       	mov    $0x3,%eax
  800de3:	e8 a2 fe ff ff       	call   800c8a <fsipc>
  800de8:	89 c3                	mov    %eax,%ebx
  800dea:	85 c0                	test   %eax,%eax
  800dec:	78 4b                	js     800e39 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800dee:	39 c6                	cmp    %eax,%esi
  800df0:	73 16                	jae    800e08 <devfile_read+0x48>
  800df2:	68 00 23 80 00       	push   $0x802300
  800df7:	68 07 23 80 00       	push   $0x802307
  800dfc:	6a 7c                	push   $0x7c
  800dfe:	68 1c 23 80 00       	push   $0x80231c
  800e03:	e8 bd 05 00 00       	call   8013c5 <_panic>
	assert(r <= PGSIZE);
  800e08:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e0d:	7e 16                	jle    800e25 <devfile_read+0x65>
  800e0f:	68 27 23 80 00       	push   $0x802327
  800e14:	68 07 23 80 00       	push   $0x802307
  800e19:	6a 7d                	push   $0x7d
  800e1b:	68 1c 23 80 00       	push   $0x80231c
  800e20:	e8 a0 05 00 00       	call   8013c5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e25:	83 ec 04             	sub    $0x4,%esp
  800e28:	50                   	push   %eax
  800e29:	68 00 50 80 00       	push   $0x805000
  800e2e:	ff 75 0c             	pushl  0xc(%ebp)
  800e31:	e8 7f 0d 00 00       	call   801bb5 <memmove>
	return r;
  800e36:	83 c4 10             	add    $0x10,%esp
}
  800e39:	89 d8                	mov    %ebx,%eax
  800e3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	53                   	push   %ebx
  800e46:	83 ec 20             	sub    $0x20,%esp
  800e49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e4c:	53                   	push   %ebx
  800e4d:	e8 98 0b 00 00       	call   8019ea <strlen>
  800e52:	83 c4 10             	add    $0x10,%esp
  800e55:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e5a:	7f 67                	jg     800ec3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e5c:	83 ec 0c             	sub    $0xc,%esp
  800e5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e62:	50                   	push   %eax
  800e63:	e8 9a f8 ff ff       	call   800702 <fd_alloc>
  800e68:	83 c4 10             	add    $0x10,%esp
		return r;
  800e6b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	78 57                	js     800ec8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e71:	83 ec 08             	sub    $0x8,%esp
  800e74:	53                   	push   %ebx
  800e75:	68 00 50 80 00       	push   $0x805000
  800e7a:	e8 a4 0b 00 00       	call   801a23 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e82:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e87:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8f:	e8 f6 fd ff ff       	call   800c8a <fsipc>
  800e94:	89 c3                	mov    %eax,%ebx
  800e96:	83 c4 10             	add    $0x10,%esp
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	79 14                	jns    800eb1 <open+0x6f>
		fd_close(fd, 0);
  800e9d:	83 ec 08             	sub    $0x8,%esp
  800ea0:	6a 00                	push   $0x0
  800ea2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea5:	e8 50 f9 ff ff       	call   8007fa <fd_close>
		return r;
  800eaa:	83 c4 10             	add    $0x10,%esp
  800ead:	89 da                	mov    %ebx,%edx
  800eaf:	eb 17                	jmp    800ec8 <open+0x86>
	}

	return fd2num(fd);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb7:	e8 1f f8 ff ff       	call   8006db <fd2num>
  800ebc:	89 c2                	mov    %eax,%edx
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	eb 05                	jmp    800ec8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ec3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ec8:	89 d0                	mov    %edx,%eax
  800eca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ecd:	c9                   	leave  
  800ece:	c3                   	ret    

00800ecf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ed5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eda:	b8 08 00 00 00       	mov    $0x8,%eax
  800edf:	e8 a6 fd ff ff       	call   800c8a <fsipc>
}
  800ee4:	c9                   	leave  
  800ee5:	c3                   	ret    

00800ee6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800eee:	83 ec 0c             	sub    $0xc,%esp
  800ef1:	ff 75 08             	pushl  0x8(%ebp)
  800ef4:	e8 f2 f7 ff ff       	call   8006eb <fd2data>
  800ef9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800efb:	83 c4 08             	add    $0x8,%esp
  800efe:	68 33 23 80 00       	push   $0x802333
  800f03:	53                   	push   %ebx
  800f04:	e8 1a 0b 00 00       	call   801a23 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f09:	8b 46 04             	mov    0x4(%esi),%eax
  800f0c:	2b 06                	sub    (%esi),%eax
  800f0e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f14:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f1b:	00 00 00 
	stat->st_dev = &devpipe;
  800f1e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f25:	30 80 00 
	return 0;
}
  800f28:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	53                   	push   %ebx
  800f38:	83 ec 0c             	sub    $0xc,%esp
  800f3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f3e:	53                   	push   %ebx
  800f3f:	6a 00                	push   $0x0
  800f41:	e8 d3 f2 ff ff       	call   800219 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f46:	89 1c 24             	mov    %ebx,(%esp)
  800f49:	e8 9d f7 ff ff       	call   8006eb <fd2data>
  800f4e:	83 c4 08             	add    $0x8,%esp
  800f51:	50                   	push   %eax
  800f52:	6a 00                	push   $0x0
  800f54:	e8 c0 f2 ff ff       	call   800219 <sys_page_unmap>
}
  800f59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f5c:	c9                   	leave  
  800f5d:	c3                   	ret    

00800f5e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f5e:	55                   	push   %ebp
  800f5f:	89 e5                	mov    %esp,%ebp
  800f61:	57                   	push   %edi
  800f62:	56                   	push   %esi
  800f63:	53                   	push   %ebx
  800f64:	83 ec 1c             	sub    $0x1c,%esp
  800f67:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f6a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f6c:	a1 04 40 80 00       	mov    0x804004,%eax
  800f71:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f74:	83 ec 0c             	sub    $0xc,%esp
  800f77:	ff 75 e0             	pushl  -0x20(%ebp)
  800f7a:	e8 70 0f 00 00       	call   801eef <pageref>
  800f7f:	89 c3                	mov    %eax,%ebx
  800f81:	89 3c 24             	mov    %edi,(%esp)
  800f84:	e8 66 0f 00 00       	call   801eef <pageref>
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	39 c3                	cmp    %eax,%ebx
  800f8e:	0f 94 c1             	sete   %cl
  800f91:	0f b6 c9             	movzbl %cl,%ecx
  800f94:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f97:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f9d:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  800fa0:	39 ce                	cmp    %ecx,%esi
  800fa2:	74 1b                	je     800fbf <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800fa4:	39 c3                	cmp    %eax,%ebx
  800fa6:	75 c4                	jne    800f6c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800fa8:	8b 42 64             	mov    0x64(%edx),%eax
  800fab:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fae:	50                   	push   %eax
  800faf:	56                   	push   %esi
  800fb0:	68 3a 23 80 00       	push   $0x80233a
  800fb5:	e8 e4 04 00 00       	call   80149e <cprintf>
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	eb ad                	jmp    800f6c <_pipeisclosed+0xe>
	}
}
  800fbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 28             	sub    $0x28,%esp
  800fd3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800fd6:	56                   	push   %esi
  800fd7:	e8 0f f7 ff ff       	call   8006eb <fd2data>
  800fdc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fde:	83 c4 10             	add    $0x10,%esp
  800fe1:	bf 00 00 00 00       	mov    $0x0,%edi
  800fe6:	eb 4b                	jmp    801033 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fe8:	89 da                	mov    %ebx,%edx
  800fea:	89 f0                	mov    %esi,%eax
  800fec:	e8 6d ff ff ff       	call   800f5e <_pipeisclosed>
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	75 48                	jne    80103d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800ff5:	e8 7b f1 ff ff       	call   800175 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ffa:	8b 43 04             	mov    0x4(%ebx),%eax
  800ffd:	8b 0b                	mov    (%ebx),%ecx
  800fff:	8d 51 20             	lea    0x20(%ecx),%edx
  801002:	39 d0                	cmp    %edx,%eax
  801004:	73 e2                	jae    800fe8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801006:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801009:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80100d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801010:	89 c2                	mov    %eax,%edx
  801012:	c1 fa 1f             	sar    $0x1f,%edx
  801015:	89 d1                	mov    %edx,%ecx
  801017:	c1 e9 1b             	shr    $0x1b,%ecx
  80101a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80101d:	83 e2 1f             	and    $0x1f,%edx
  801020:	29 ca                	sub    %ecx,%edx
  801022:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801026:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80102a:	83 c0 01             	add    $0x1,%eax
  80102d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801030:	83 c7 01             	add    $0x1,%edi
  801033:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801036:	75 c2                	jne    800ffa <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801038:	8b 45 10             	mov    0x10(%ebp),%eax
  80103b:	eb 05                	jmp    801042 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80103d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801042:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801045:	5b                   	pop    %ebx
  801046:	5e                   	pop    %esi
  801047:	5f                   	pop    %edi
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    

0080104a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	57                   	push   %edi
  80104e:	56                   	push   %esi
  80104f:	53                   	push   %ebx
  801050:	83 ec 18             	sub    $0x18,%esp
  801053:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801056:	57                   	push   %edi
  801057:	e8 8f f6 ff ff       	call   8006eb <fd2data>
  80105c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80105e:	83 c4 10             	add    $0x10,%esp
  801061:	bb 00 00 00 00       	mov    $0x0,%ebx
  801066:	eb 3d                	jmp    8010a5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801068:	85 db                	test   %ebx,%ebx
  80106a:	74 04                	je     801070 <devpipe_read+0x26>
				return i;
  80106c:	89 d8                	mov    %ebx,%eax
  80106e:	eb 44                	jmp    8010b4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801070:	89 f2                	mov    %esi,%edx
  801072:	89 f8                	mov    %edi,%eax
  801074:	e8 e5 fe ff ff       	call   800f5e <_pipeisclosed>
  801079:	85 c0                	test   %eax,%eax
  80107b:	75 32                	jne    8010af <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80107d:	e8 f3 f0 ff ff       	call   800175 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801082:	8b 06                	mov    (%esi),%eax
  801084:	3b 46 04             	cmp    0x4(%esi),%eax
  801087:	74 df                	je     801068 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801089:	99                   	cltd   
  80108a:	c1 ea 1b             	shr    $0x1b,%edx
  80108d:	01 d0                	add    %edx,%eax
  80108f:	83 e0 1f             	and    $0x1f,%eax
  801092:	29 d0                	sub    %edx,%eax
  801094:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801099:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80109f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010a2:	83 c3 01             	add    $0x1,%ebx
  8010a5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010a8:	75 d8                	jne    801082 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8010aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8010ad:	eb 05                	jmp    8010b4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010af:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8010b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b7:	5b                   	pop    %ebx
  8010b8:	5e                   	pop    %esi
  8010b9:	5f                   	pop    %edi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	56                   	push   %esi
  8010c0:	53                   	push   %ebx
  8010c1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8010c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c7:	50                   	push   %eax
  8010c8:	e8 35 f6 ff ff       	call   800702 <fd_alloc>
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	89 c2                	mov    %eax,%edx
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	0f 88 2c 01 00 00    	js     801206 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010da:	83 ec 04             	sub    $0x4,%esp
  8010dd:	68 07 04 00 00       	push   $0x407
  8010e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8010e5:	6a 00                	push   $0x0
  8010e7:	e8 a8 f0 ff ff       	call   800194 <sys_page_alloc>
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	89 c2                	mov    %eax,%edx
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	0f 88 0d 01 00 00    	js     801206 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010f9:	83 ec 0c             	sub    $0xc,%esp
  8010fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ff:	50                   	push   %eax
  801100:	e8 fd f5 ff ff       	call   800702 <fd_alloc>
  801105:	89 c3                	mov    %eax,%ebx
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	0f 88 e2 00 00 00    	js     8011f4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801112:	83 ec 04             	sub    $0x4,%esp
  801115:	68 07 04 00 00       	push   $0x407
  80111a:	ff 75 f0             	pushl  -0x10(%ebp)
  80111d:	6a 00                	push   $0x0
  80111f:	e8 70 f0 ff ff       	call   800194 <sys_page_alloc>
  801124:	89 c3                	mov    %eax,%ebx
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	0f 88 c3 00 00 00    	js     8011f4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801131:	83 ec 0c             	sub    $0xc,%esp
  801134:	ff 75 f4             	pushl  -0xc(%ebp)
  801137:	e8 af f5 ff ff       	call   8006eb <fd2data>
  80113c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80113e:	83 c4 0c             	add    $0xc,%esp
  801141:	68 07 04 00 00       	push   $0x407
  801146:	50                   	push   %eax
  801147:	6a 00                	push   $0x0
  801149:	e8 46 f0 ff ff       	call   800194 <sys_page_alloc>
  80114e:	89 c3                	mov    %eax,%ebx
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	0f 88 89 00 00 00    	js     8011e4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80115b:	83 ec 0c             	sub    $0xc,%esp
  80115e:	ff 75 f0             	pushl  -0x10(%ebp)
  801161:	e8 85 f5 ff ff       	call   8006eb <fd2data>
  801166:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80116d:	50                   	push   %eax
  80116e:	6a 00                	push   $0x0
  801170:	56                   	push   %esi
  801171:	6a 00                	push   $0x0
  801173:	e8 5f f0 ff ff       	call   8001d7 <sys_page_map>
  801178:	89 c3                	mov    %eax,%ebx
  80117a:	83 c4 20             	add    $0x20,%esp
  80117d:	85 c0                	test   %eax,%eax
  80117f:	78 55                	js     8011d6 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801181:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801187:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80118c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801196:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80119c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8011a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8011ab:	83 ec 0c             	sub    $0xc,%esp
  8011ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8011b1:	e8 25 f5 ff ff       	call   8006db <fd2num>
  8011b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8011bb:	83 c4 04             	add    $0x4,%esp
  8011be:	ff 75 f0             	pushl  -0x10(%ebp)
  8011c1:	e8 15 f5 ff ff       	call   8006db <fd2num>
  8011c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c9:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d4:	eb 30                	jmp    801206 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011d6:	83 ec 08             	sub    $0x8,%esp
  8011d9:	56                   	push   %esi
  8011da:	6a 00                	push   $0x0
  8011dc:	e8 38 f0 ff ff       	call   800219 <sys_page_unmap>
  8011e1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8011ea:	6a 00                	push   $0x0
  8011ec:	e8 28 f0 ff ff       	call   800219 <sys_page_unmap>
  8011f1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011f4:	83 ec 08             	sub    $0x8,%esp
  8011f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8011fa:	6a 00                	push   $0x0
  8011fc:	e8 18 f0 ff ff       	call   800219 <sys_page_unmap>
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801206:	89 d0                	mov    %edx,%eax
  801208:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5e                   	pop    %esi
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    

0080120f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801215:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	ff 75 08             	pushl  0x8(%ebp)
  80121c:	e8 30 f5 ff ff       	call   800751 <fd_lookup>
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	78 18                	js     801240 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801228:	83 ec 0c             	sub    $0xc,%esp
  80122b:	ff 75 f4             	pushl  -0xc(%ebp)
  80122e:	e8 b8 f4 ff ff       	call   8006eb <fd2data>
	return _pipeisclosed(fd, p);
  801233:	89 c2                	mov    %eax,%edx
  801235:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801238:	e8 21 fd ff ff       	call   800f5e <_pipeisclosed>
  80123d:	83 c4 10             	add    $0x10,%esp
}
  801240:	c9                   	leave  
  801241:	c3                   	ret    

00801242 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801245:	b8 00 00 00 00       	mov    $0x0,%eax
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    

0080124c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801252:	68 52 23 80 00       	push   $0x802352
  801257:	ff 75 0c             	pushl  0xc(%ebp)
  80125a:	e8 c4 07 00 00       	call   801a23 <strcpy>
	return 0;
}
  80125f:	b8 00 00 00 00       	mov    $0x0,%eax
  801264:	c9                   	leave  
  801265:	c3                   	ret    

00801266 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	57                   	push   %edi
  80126a:	56                   	push   %esi
  80126b:	53                   	push   %ebx
  80126c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801272:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801277:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80127d:	eb 2d                	jmp    8012ac <devcons_write+0x46>
		m = n - tot;
  80127f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801282:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801284:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801287:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80128c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80128f:	83 ec 04             	sub    $0x4,%esp
  801292:	53                   	push   %ebx
  801293:	03 45 0c             	add    0xc(%ebp),%eax
  801296:	50                   	push   %eax
  801297:	57                   	push   %edi
  801298:	e8 18 09 00 00       	call   801bb5 <memmove>
		sys_cputs(buf, m);
  80129d:	83 c4 08             	add    $0x8,%esp
  8012a0:	53                   	push   %ebx
  8012a1:	57                   	push   %edi
  8012a2:	e8 31 ee ff ff       	call   8000d8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012a7:	01 de                	add    %ebx,%esi
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	89 f0                	mov    %esi,%eax
  8012ae:	3b 75 10             	cmp    0x10(%ebp),%esi
  8012b1:	72 cc                	jb     80127f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8012b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b6:	5b                   	pop    %ebx
  8012b7:	5e                   	pop    %esi
  8012b8:	5f                   	pop    %edi
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    

008012bb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	83 ec 08             	sub    $0x8,%esp
  8012c1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8012c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012ca:	74 2a                	je     8012f6 <devcons_read+0x3b>
  8012cc:	eb 05                	jmp    8012d3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012ce:	e8 a2 ee ff ff       	call   800175 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012d3:	e8 1e ee ff ff       	call   8000f6 <sys_cgetc>
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	74 f2                	je     8012ce <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 16                	js     8012f6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012e0:	83 f8 04             	cmp    $0x4,%eax
  8012e3:	74 0c                	je     8012f1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e8:	88 02                	mov    %al,(%edx)
	return 1;
  8012ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8012ef:	eb 05                	jmp    8012f6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012f1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012f6:	c9                   	leave  
  8012f7:	c3                   	ret    

008012f8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801301:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801304:	6a 01                	push   $0x1
  801306:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801309:	50                   	push   %eax
  80130a:	e8 c9 ed ff ff       	call   8000d8 <sys_cputs>
}
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	c9                   	leave  
  801313:	c3                   	ret    

00801314 <getchar>:

int
getchar(void)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80131a:	6a 01                	push   $0x1
  80131c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80131f:	50                   	push   %eax
  801320:	6a 00                	push   $0x0
  801322:	e8 90 f6 ff ff       	call   8009b7 <read>
	if (r < 0)
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	85 c0                	test   %eax,%eax
  80132c:	78 0f                	js     80133d <getchar+0x29>
		return r;
	if (r < 1)
  80132e:	85 c0                	test   %eax,%eax
  801330:	7e 06                	jle    801338 <getchar+0x24>
		return -E_EOF;
	return c;
  801332:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801336:	eb 05                	jmp    80133d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801338:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801345:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801348:	50                   	push   %eax
  801349:	ff 75 08             	pushl  0x8(%ebp)
  80134c:	e8 00 f4 ff ff       	call   800751 <fd_lookup>
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	85 c0                	test   %eax,%eax
  801356:	78 11                	js     801369 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801361:	39 10                	cmp    %edx,(%eax)
  801363:	0f 94 c0             	sete   %al
  801366:	0f b6 c0             	movzbl %al,%eax
}
  801369:	c9                   	leave  
  80136a:	c3                   	ret    

0080136b <opencons>:

int
opencons(void)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801371:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801374:	50                   	push   %eax
  801375:	e8 88 f3 ff ff       	call   800702 <fd_alloc>
  80137a:	83 c4 10             	add    $0x10,%esp
		return r;
  80137d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 3e                	js     8013c1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801383:	83 ec 04             	sub    $0x4,%esp
  801386:	68 07 04 00 00       	push   $0x407
  80138b:	ff 75 f4             	pushl  -0xc(%ebp)
  80138e:	6a 00                	push   $0x0
  801390:	e8 ff ed ff ff       	call   800194 <sys_page_alloc>
  801395:	83 c4 10             	add    $0x10,%esp
		return r;
  801398:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 23                	js     8013c1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80139e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8013a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ac:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	50                   	push   %eax
  8013b7:	e8 1f f3 ff ff       	call   8006db <fd2num>
  8013bc:	89 c2                	mov    %eax,%edx
  8013be:	83 c4 10             	add    $0x10,%esp
}
  8013c1:	89 d0                	mov    %edx,%eax
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	56                   	push   %esi
  8013c9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013ca:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013cd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013d3:	e8 7e ed ff ff       	call   800156 <sys_getenvid>
  8013d8:	83 ec 0c             	sub    $0xc,%esp
  8013db:	ff 75 0c             	pushl  0xc(%ebp)
  8013de:	ff 75 08             	pushl  0x8(%ebp)
  8013e1:	56                   	push   %esi
  8013e2:	50                   	push   %eax
  8013e3:	68 60 23 80 00       	push   $0x802360
  8013e8:	e8 b1 00 00 00       	call   80149e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013ed:	83 c4 18             	add    $0x18,%esp
  8013f0:	53                   	push   %ebx
  8013f1:	ff 75 10             	pushl  0x10(%ebp)
  8013f4:	e8 54 00 00 00       	call   80144d <vcprintf>
	cprintf("\n");
  8013f9:	c7 04 24 4b 23 80 00 	movl   $0x80234b,(%esp)
  801400:	e8 99 00 00 00       	call   80149e <cprintf>
  801405:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801408:	cc                   	int3   
  801409:	eb fd                	jmp    801408 <_panic+0x43>

0080140b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	53                   	push   %ebx
  80140f:	83 ec 04             	sub    $0x4,%esp
  801412:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801415:	8b 13                	mov    (%ebx),%edx
  801417:	8d 42 01             	lea    0x1(%edx),%eax
  80141a:	89 03                	mov    %eax,(%ebx)
  80141c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80141f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801423:	3d ff 00 00 00       	cmp    $0xff,%eax
  801428:	75 1a                	jne    801444 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80142a:	83 ec 08             	sub    $0x8,%esp
  80142d:	68 ff 00 00 00       	push   $0xff
  801432:	8d 43 08             	lea    0x8(%ebx),%eax
  801435:	50                   	push   %eax
  801436:	e8 9d ec ff ff       	call   8000d8 <sys_cputs>
		b->idx = 0;
  80143b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801441:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801444:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801448:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144b:	c9                   	leave  
  80144c:	c3                   	ret    

0080144d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801456:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80145d:	00 00 00 
	b.cnt = 0;
  801460:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801467:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80146a:	ff 75 0c             	pushl  0xc(%ebp)
  80146d:	ff 75 08             	pushl  0x8(%ebp)
  801470:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801476:	50                   	push   %eax
  801477:	68 0b 14 80 00       	push   $0x80140b
  80147c:	e8 54 01 00 00       	call   8015d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801481:	83 c4 08             	add    $0x8,%esp
  801484:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80148a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801490:	50                   	push   %eax
  801491:	e8 42 ec ff ff       	call   8000d8 <sys_cputs>

	return b.cnt;
}
  801496:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80149c:	c9                   	leave  
  80149d:	c3                   	ret    

0080149e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014a4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8014a7:	50                   	push   %eax
  8014a8:	ff 75 08             	pushl  0x8(%ebp)
  8014ab:	e8 9d ff ff ff       	call   80144d <vcprintf>
	va_end(ap);

	return cnt;
}
  8014b0:	c9                   	leave  
  8014b1:	c3                   	ret    

008014b2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	57                   	push   %edi
  8014b6:	56                   	push   %esi
  8014b7:	53                   	push   %ebx
  8014b8:	83 ec 1c             	sub    $0x1c,%esp
  8014bb:	89 c7                	mov    %eax,%edi
  8014bd:	89 d6                	mov    %edx,%esi
  8014bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014d6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014d9:	39 d3                	cmp    %edx,%ebx
  8014db:	72 05                	jb     8014e2 <printnum+0x30>
  8014dd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014e0:	77 45                	ja     801527 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014e2:	83 ec 0c             	sub    $0xc,%esp
  8014e5:	ff 75 18             	pushl  0x18(%ebp)
  8014e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014eb:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014ee:	53                   	push   %ebx
  8014ef:	ff 75 10             	pushl  0x10(%ebp)
  8014f2:	83 ec 08             	sub    $0x8,%esp
  8014f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8014fb:	ff 75 dc             	pushl  -0x24(%ebp)
  8014fe:	ff 75 d8             	pushl  -0x28(%ebp)
  801501:	e8 2a 0a 00 00       	call   801f30 <__udivdi3>
  801506:	83 c4 18             	add    $0x18,%esp
  801509:	52                   	push   %edx
  80150a:	50                   	push   %eax
  80150b:	89 f2                	mov    %esi,%edx
  80150d:	89 f8                	mov    %edi,%eax
  80150f:	e8 9e ff ff ff       	call   8014b2 <printnum>
  801514:	83 c4 20             	add    $0x20,%esp
  801517:	eb 18                	jmp    801531 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	56                   	push   %esi
  80151d:	ff 75 18             	pushl  0x18(%ebp)
  801520:	ff d7                	call   *%edi
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	eb 03                	jmp    80152a <printnum+0x78>
  801527:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80152a:	83 eb 01             	sub    $0x1,%ebx
  80152d:	85 db                	test   %ebx,%ebx
  80152f:	7f e8                	jg     801519 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801531:	83 ec 08             	sub    $0x8,%esp
  801534:	56                   	push   %esi
  801535:	83 ec 04             	sub    $0x4,%esp
  801538:	ff 75 e4             	pushl  -0x1c(%ebp)
  80153b:	ff 75 e0             	pushl  -0x20(%ebp)
  80153e:	ff 75 dc             	pushl  -0x24(%ebp)
  801541:	ff 75 d8             	pushl  -0x28(%ebp)
  801544:	e8 17 0b 00 00       	call   802060 <__umoddi3>
  801549:	83 c4 14             	add    $0x14,%esp
  80154c:	0f be 80 83 23 80 00 	movsbl 0x802383(%eax),%eax
  801553:	50                   	push   %eax
  801554:	ff d7                	call   *%edi
}
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80155c:	5b                   	pop    %ebx
  80155d:	5e                   	pop    %esi
  80155e:	5f                   	pop    %edi
  80155f:	5d                   	pop    %ebp
  801560:	c3                   	ret    

00801561 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801564:	83 fa 01             	cmp    $0x1,%edx
  801567:	7e 0e                	jle    801577 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801569:	8b 10                	mov    (%eax),%edx
  80156b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80156e:	89 08                	mov    %ecx,(%eax)
  801570:	8b 02                	mov    (%edx),%eax
  801572:	8b 52 04             	mov    0x4(%edx),%edx
  801575:	eb 22                	jmp    801599 <getuint+0x38>
	else if (lflag)
  801577:	85 d2                	test   %edx,%edx
  801579:	74 10                	je     80158b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80157b:	8b 10                	mov    (%eax),%edx
  80157d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801580:	89 08                	mov    %ecx,(%eax)
  801582:	8b 02                	mov    (%edx),%eax
  801584:	ba 00 00 00 00       	mov    $0x0,%edx
  801589:	eb 0e                	jmp    801599 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80158b:	8b 10                	mov    (%eax),%edx
  80158d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801590:	89 08                	mov    %ecx,(%eax)
  801592:	8b 02                	mov    (%edx),%eax
  801594:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801599:	5d                   	pop    %ebp
  80159a:	c3                   	ret    

0080159b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015a1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8015a5:	8b 10                	mov    (%eax),%edx
  8015a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8015aa:	73 0a                	jae    8015b6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8015ac:	8d 4a 01             	lea    0x1(%edx),%ecx
  8015af:	89 08                	mov    %ecx,(%eax)
  8015b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b4:	88 02                	mov    %al,(%edx)
}
  8015b6:	5d                   	pop    %ebp
  8015b7:	c3                   	ret    

008015b8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8015be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015c1:	50                   	push   %eax
  8015c2:	ff 75 10             	pushl  0x10(%ebp)
  8015c5:	ff 75 0c             	pushl  0xc(%ebp)
  8015c8:	ff 75 08             	pushl  0x8(%ebp)
  8015cb:	e8 05 00 00 00       	call   8015d5 <vprintfmt>
	va_end(ap);
}
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	c9                   	leave  
  8015d4:	c3                   	ret    

008015d5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	57                   	push   %edi
  8015d9:	56                   	push   %esi
  8015da:	53                   	push   %ebx
  8015db:	83 ec 2c             	sub    $0x2c,%esp
  8015de:	8b 75 08             	mov    0x8(%ebp),%esi
  8015e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015e4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015e7:	eb 12                	jmp    8015fb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	0f 84 89 03 00 00    	je     80197a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	53                   	push   %ebx
  8015f5:	50                   	push   %eax
  8015f6:	ff d6                	call   *%esi
  8015f8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015fb:	83 c7 01             	add    $0x1,%edi
  8015fe:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801602:	83 f8 25             	cmp    $0x25,%eax
  801605:	75 e2                	jne    8015e9 <vprintfmt+0x14>
  801607:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80160b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801612:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801619:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801620:	ba 00 00 00 00       	mov    $0x0,%edx
  801625:	eb 07                	jmp    80162e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801627:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80162a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80162e:	8d 47 01             	lea    0x1(%edi),%eax
  801631:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801634:	0f b6 07             	movzbl (%edi),%eax
  801637:	0f b6 c8             	movzbl %al,%ecx
  80163a:	83 e8 23             	sub    $0x23,%eax
  80163d:	3c 55                	cmp    $0x55,%al
  80163f:	0f 87 1a 03 00 00    	ja     80195f <vprintfmt+0x38a>
  801645:	0f b6 c0             	movzbl %al,%eax
  801648:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  80164f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801652:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801656:	eb d6                	jmp    80162e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80165b:	b8 00 00 00 00       	mov    $0x0,%eax
  801660:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801663:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801666:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80166a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80166d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801670:	83 fa 09             	cmp    $0x9,%edx
  801673:	77 39                	ja     8016ae <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801675:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801678:	eb e9                	jmp    801663 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80167a:	8b 45 14             	mov    0x14(%ebp),%eax
  80167d:	8d 48 04             	lea    0x4(%eax),%ecx
  801680:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801683:	8b 00                	mov    (%eax),%eax
  801685:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801688:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80168b:	eb 27                	jmp    8016b4 <vprintfmt+0xdf>
  80168d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801690:	85 c0                	test   %eax,%eax
  801692:	b9 00 00 00 00       	mov    $0x0,%ecx
  801697:	0f 49 c8             	cmovns %eax,%ecx
  80169a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80169d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016a0:	eb 8c                	jmp    80162e <vprintfmt+0x59>
  8016a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8016a5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8016ac:	eb 80                	jmp    80162e <vprintfmt+0x59>
  8016ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016b1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8016b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016b8:	0f 89 70 ff ff ff    	jns    80162e <vprintfmt+0x59>
				width = precision, precision = -1;
  8016be:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8016c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016c4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016cb:	e9 5e ff ff ff       	jmp    80162e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016d0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016d6:	e9 53 ff ff ff       	jmp    80162e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016db:	8b 45 14             	mov    0x14(%ebp),%eax
  8016de:	8d 50 04             	lea    0x4(%eax),%edx
  8016e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8016e4:	83 ec 08             	sub    $0x8,%esp
  8016e7:	53                   	push   %ebx
  8016e8:	ff 30                	pushl  (%eax)
  8016ea:	ff d6                	call   *%esi
			break;
  8016ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016f2:	e9 04 ff ff ff       	jmp    8015fb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8016fa:	8d 50 04             	lea    0x4(%eax),%edx
  8016fd:	89 55 14             	mov    %edx,0x14(%ebp)
  801700:	8b 00                	mov    (%eax),%eax
  801702:	99                   	cltd   
  801703:	31 d0                	xor    %edx,%eax
  801705:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801707:	83 f8 0f             	cmp    $0xf,%eax
  80170a:	7f 0b                	jg     801717 <vprintfmt+0x142>
  80170c:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  801713:	85 d2                	test   %edx,%edx
  801715:	75 18                	jne    80172f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801717:	50                   	push   %eax
  801718:	68 9b 23 80 00       	push   $0x80239b
  80171d:	53                   	push   %ebx
  80171e:	56                   	push   %esi
  80171f:	e8 94 fe ff ff       	call   8015b8 <printfmt>
  801724:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801727:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80172a:	e9 cc fe ff ff       	jmp    8015fb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80172f:	52                   	push   %edx
  801730:	68 19 23 80 00       	push   $0x802319
  801735:	53                   	push   %ebx
  801736:	56                   	push   %esi
  801737:	e8 7c fe ff ff       	call   8015b8 <printfmt>
  80173c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80173f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801742:	e9 b4 fe ff ff       	jmp    8015fb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801747:	8b 45 14             	mov    0x14(%ebp),%eax
  80174a:	8d 50 04             	lea    0x4(%eax),%edx
  80174d:	89 55 14             	mov    %edx,0x14(%ebp)
  801750:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801752:	85 ff                	test   %edi,%edi
  801754:	b8 94 23 80 00       	mov    $0x802394,%eax
  801759:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80175c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801760:	0f 8e 94 00 00 00    	jle    8017fa <vprintfmt+0x225>
  801766:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80176a:	0f 84 98 00 00 00    	je     801808 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801770:	83 ec 08             	sub    $0x8,%esp
  801773:	ff 75 d0             	pushl  -0x30(%ebp)
  801776:	57                   	push   %edi
  801777:	e8 86 02 00 00       	call   801a02 <strnlen>
  80177c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80177f:	29 c1                	sub    %eax,%ecx
  801781:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801784:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801787:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80178b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80178e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801791:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801793:	eb 0f                	jmp    8017a4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801795:	83 ec 08             	sub    $0x8,%esp
  801798:	53                   	push   %ebx
  801799:	ff 75 e0             	pushl  -0x20(%ebp)
  80179c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80179e:	83 ef 01             	sub    $0x1,%edi
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	85 ff                	test   %edi,%edi
  8017a6:	7f ed                	jg     801795 <vprintfmt+0x1c0>
  8017a8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017ab:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8017ae:	85 c9                	test   %ecx,%ecx
  8017b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b5:	0f 49 c1             	cmovns %ecx,%eax
  8017b8:	29 c1                	sub    %eax,%ecx
  8017ba:	89 75 08             	mov    %esi,0x8(%ebp)
  8017bd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017c0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017c3:	89 cb                	mov    %ecx,%ebx
  8017c5:	eb 4d                	jmp    801814 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017c7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017cb:	74 1b                	je     8017e8 <vprintfmt+0x213>
  8017cd:	0f be c0             	movsbl %al,%eax
  8017d0:	83 e8 20             	sub    $0x20,%eax
  8017d3:	83 f8 5e             	cmp    $0x5e,%eax
  8017d6:	76 10                	jbe    8017e8 <vprintfmt+0x213>
					putch('?', putdat);
  8017d8:	83 ec 08             	sub    $0x8,%esp
  8017db:	ff 75 0c             	pushl  0xc(%ebp)
  8017de:	6a 3f                	push   $0x3f
  8017e0:	ff 55 08             	call   *0x8(%ebp)
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	eb 0d                	jmp    8017f5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ee:	52                   	push   %edx
  8017ef:	ff 55 08             	call   *0x8(%ebp)
  8017f2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017f5:	83 eb 01             	sub    $0x1,%ebx
  8017f8:	eb 1a                	jmp    801814 <vprintfmt+0x23f>
  8017fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8017fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801800:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801803:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801806:	eb 0c                	jmp    801814 <vprintfmt+0x23f>
  801808:	89 75 08             	mov    %esi,0x8(%ebp)
  80180b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80180e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801811:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801814:	83 c7 01             	add    $0x1,%edi
  801817:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80181b:	0f be d0             	movsbl %al,%edx
  80181e:	85 d2                	test   %edx,%edx
  801820:	74 23                	je     801845 <vprintfmt+0x270>
  801822:	85 f6                	test   %esi,%esi
  801824:	78 a1                	js     8017c7 <vprintfmt+0x1f2>
  801826:	83 ee 01             	sub    $0x1,%esi
  801829:	79 9c                	jns    8017c7 <vprintfmt+0x1f2>
  80182b:	89 df                	mov    %ebx,%edi
  80182d:	8b 75 08             	mov    0x8(%ebp),%esi
  801830:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801833:	eb 18                	jmp    80184d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801835:	83 ec 08             	sub    $0x8,%esp
  801838:	53                   	push   %ebx
  801839:	6a 20                	push   $0x20
  80183b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80183d:	83 ef 01             	sub    $0x1,%edi
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	eb 08                	jmp    80184d <vprintfmt+0x278>
  801845:	89 df                	mov    %ebx,%edi
  801847:	8b 75 08             	mov    0x8(%ebp),%esi
  80184a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80184d:	85 ff                	test   %edi,%edi
  80184f:	7f e4                	jg     801835 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801851:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801854:	e9 a2 fd ff ff       	jmp    8015fb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801859:	83 fa 01             	cmp    $0x1,%edx
  80185c:	7e 16                	jle    801874 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80185e:	8b 45 14             	mov    0x14(%ebp),%eax
  801861:	8d 50 08             	lea    0x8(%eax),%edx
  801864:	89 55 14             	mov    %edx,0x14(%ebp)
  801867:	8b 50 04             	mov    0x4(%eax),%edx
  80186a:	8b 00                	mov    (%eax),%eax
  80186c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80186f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801872:	eb 32                	jmp    8018a6 <vprintfmt+0x2d1>
	else if (lflag)
  801874:	85 d2                	test   %edx,%edx
  801876:	74 18                	je     801890 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801878:	8b 45 14             	mov    0x14(%ebp),%eax
  80187b:	8d 50 04             	lea    0x4(%eax),%edx
  80187e:	89 55 14             	mov    %edx,0x14(%ebp)
  801881:	8b 00                	mov    (%eax),%eax
  801883:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801886:	89 c1                	mov    %eax,%ecx
  801888:	c1 f9 1f             	sar    $0x1f,%ecx
  80188b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80188e:	eb 16                	jmp    8018a6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801890:	8b 45 14             	mov    0x14(%ebp),%eax
  801893:	8d 50 04             	lea    0x4(%eax),%edx
  801896:	89 55 14             	mov    %edx,0x14(%ebp)
  801899:	8b 00                	mov    (%eax),%eax
  80189b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80189e:	89 c1                	mov    %eax,%ecx
  8018a0:	c1 f9 1f             	sar    $0x1f,%ecx
  8018a3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8018a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8018ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8018b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018b5:	79 74                	jns    80192b <vprintfmt+0x356>
				putch('-', putdat);
  8018b7:	83 ec 08             	sub    $0x8,%esp
  8018ba:	53                   	push   %ebx
  8018bb:	6a 2d                	push   $0x2d
  8018bd:	ff d6                	call   *%esi
				num = -(long long) num;
  8018bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8018c5:	f7 d8                	neg    %eax
  8018c7:	83 d2 00             	adc    $0x0,%edx
  8018ca:	f7 da                	neg    %edx
  8018cc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018cf:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018d4:	eb 55                	jmp    80192b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8018d9:	e8 83 fc ff ff       	call   801561 <getuint>
			base = 10;
  8018de:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018e3:	eb 46                	jmp    80192b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8018e8:	e8 74 fc ff ff       	call   801561 <getuint>
			base = 8;
  8018ed:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018f2:	eb 37                	jmp    80192b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	53                   	push   %ebx
  8018f8:	6a 30                	push   $0x30
  8018fa:	ff d6                	call   *%esi
			putch('x', putdat);
  8018fc:	83 c4 08             	add    $0x8,%esp
  8018ff:	53                   	push   %ebx
  801900:	6a 78                	push   $0x78
  801902:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801904:	8b 45 14             	mov    0x14(%ebp),%eax
  801907:	8d 50 04             	lea    0x4(%eax),%edx
  80190a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80190d:	8b 00                	mov    (%eax),%eax
  80190f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801914:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801917:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80191c:	eb 0d                	jmp    80192b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80191e:	8d 45 14             	lea    0x14(%ebp),%eax
  801921:	e8 3b fc ff ff       	call   801561 <getuint>
			base = 16;
  801926:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80192b:	83 ec 0c             	sub    $0xc,%esp
  80192e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801932:	57                   	push   %edi
  801933:	ff 75 e0             	pushl  -0x20(%ebp)
  801936:	51                   	push   %ecx
  801937:	52                   	push   %edx
  801938:	50                   	push   %eax
  801939:	89 da                	mov    %ebx,%edx
  80193b:	89 f0                	mov    %esi,%eax
  80193d:	e8 70 fb ff ff       	call   8014b2 <printnum>
			break;
  801942:	83 c4 20             	add    $0x20,%esp
  801945:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801948:	e9 ae fc ff ff       	jmp    8015fb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80194d:	83 ec 08             	sub    $0x8,%esp
  801950:	53                   	push   %ebx
  801951:	51                   	push   %ecx
  801952:	ff d6                	call   *%esi
			break;
  801954:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801957:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80195a:	e9 9c fc ff ff       	jmp    8015fb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80195f:	83 ec 08             	sub    $0x8,%esp
  801962:	53                   	push   %ebx
  801963:	6a 25                	push   $0x25
  801965:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801967:	83 c4 10             	add    $0x10,%esp
  80196a:	eb 03                	jmp    80196f <vprintfmt+0x39a>
  80196c:	83 ef 01             	sub    $0x1,%edi
  80196f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801973:	75 f7                	jne    80196c <vprintfmt+0x397>
  801975:	e9 81 fc ff ff       	jmp    8015fb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80197a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80197d:	5b                   	pop    %ebx
  80197e:	5e                   	pop    %esi
  80197f:	5f                   	pop    %edi
  801980:	5d                   	pop    %ebp
  801981:	c3                   	ret    

00801982 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	83 ec 18             	sub    $0x18,%esp
  801988:	8b 45 08             	mov    0x8(%ebp),%eax
  80198b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80198e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801991:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801995:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801998:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	74 26                	je     8019c9 <vsnprintf+0x47>
  8019a3:	85 d2                	test   %edx,%edx
  8019a5:	7e 22                	jle    8019c9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8019a7:	ff 75 14             	pushl  0x14(%ebp)
  8019aa:	ff 75 10             	pushl  0x10(%ebp)
  8019ad:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019b0:	50                   	push   %eax
  8019b1:	68 9b 15 80 00       	push   $0x80159b
  8019b6:	e8 1a fc ff ff       	call   8015d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019be:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	eb 05                	jmp    8019ce <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019d6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019d9:	50                   	push   %eax
  8019da:	ff 75 10             	pushl  0x10(%ebp)
  8019dd:	ff 75 0c             	pushl  0xc(%ebp)
  8019e0:	ff 75 08             	pushl  0x8(%ebp)
  8019e3:	e8 9a ff ff ff       	call   801982 <vsnprintf>
	va_end(ap);

	return rc;
}
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f5:	eb 03                	jmp    8019fa <strlen+0x10>
		n++;
  8019f7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019fa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019fe:	75 f7                	jne    8019f7 <strlen+0xd>
		n++;
	return n;
}
  801a00:	5d                   	pop    %ebp
  801a01:	c3                   	ret    

00801a02 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a08:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a10:	eb 03                	jmp    801a15 <strnlen+0x13>
		n++;
  801a12:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a15:	39 c2                	cmp    %eax,%edx
  801a17:	74 08                	je     801a21 <strnlen+0x1f>
  801a19:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801a1d:	75 f3                	jne    801a12 <strnlen+0x10>
  801a1f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a21:	5d                   	pop    %ebp
  801a22:	c3                   	ret    

00801a23 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	53                   	push   %ebx
  801a27:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a2d:	89 c2                	mov    %eax,%edx
  801a2f:	83 c2 01             	add    $0x1,%edx
  801a32:	83 c1 01             	add    $0x1,%ecx
  801a35:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a39:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a3c:	84 db                	test   %bl,%bl
  801a3e:	75 ef                	jne    801a2f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a40:	5b                   	pop    %ebx
  801a41:	5d                   	pop    %ebp
  801a42:	c3                   	ret    

00801a43 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	53                   	push   %ebx
  801a47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a4a:	53                   	push   %ebx
  801a4b:	e8 9a ff ff ff       	call   8019ea <strlen>
  801a50:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a53:	ff 75 0c             	pushl  0xc(%ebp)
  801a56:	01 d8                	add    %ebx,%eax
  801a58:	50                   	push   %eax
  801a59:	e8 c5 ff ff ff       	call   801a23 <strcpy>
	return dst;
}
  801a5e:	89 d8                	mov    %ebx,%eax
  801a60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a63:	c9                   	leave  
  801a64:	c3                   	ret    

00801a65 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	56                   	push   %esi
  801a69:	53                   	push   %ebx
  801a6a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a70:	89 f3                	mov    %esi,%ebx
  801a72:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a75:	89 f2                	mov    %esi,%edx
  801a77:	eb 0f                	jmp    801a88 <strncpy+0x23>
		*dst++ = *src;
  801a79:	83 c2 01             	add    $0x1,%edx
  801a7c:	0f b6 01             	movzbl (%ecx),%eax
  801a7f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a82:	80 39 01             	cmpb   $0x1,(%ecx)
  801a85:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a88:	39 da                	cmp    %ebx,%edx
  801a8a:	75 ed                	jne    801a79 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a8c:	89 f0                	mov    %esi,%eax
  801a8e:	5b                   	pop    %ebx
  801a8f:	5e                   	pop    %esi
  801a90:	5d                   	pop    %ebp
  801a91:	c3                   	ret    

00801a92 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	56                   	push   %esi
  801a96:	53                   	push   %ebx
  801a97:	8b 75 08             	mov    0x8(%ebp),%esi
  801a9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9d:	8b 55 10             	mov    0x10(%ebp),%edx
  801aa0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801aa2:	85 d2                	test   %edx,%edx
  801aa4:	74 21                	je     801ac7 <strlcpy+0x35>
  801aa6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801aaa:	89 f2                	mov    %esi,%edx
  801aac:	eb 09                	jmp    801ab7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801aae:	83 c2 01             	add    $0x1,%edx
  801ab1:	83 c1 01             	add    $0x1,%ecx
  801ab4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ab7:	39 c2                	cmp    %eax,%edx
  801ab9:	74 09                	je     801ac4 <strlcpy+0x32>
  801abb:	0f b6 19             	movzbl (%ecx),%ebx
  801abe:	84 db                	test   %bl,%bl
  801ac0:	75 ec                	jne    801aae <strlcpy+0x1c>
  801ac2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801ac4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801ac7:	29 f0                	sub    %esi,%eax
}
  801ac9:	5b                   	pop    %ebx
  801aca:	5e                   	pop    %esi
  801acb:	5d                   	pop    %ebp
  801acc:	c3                   	ret    

00801acd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ad3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801ad6:	eb 06                	jmp    801ade <strcmp+0x11>
		p++, q++;
  801ad8:	83 c1 01             	add    $0x1,%ecx
  801adb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801ade:	0f b6 01             	movzbl (%ecx),%eax
  801ae1:	84 c0                	test   %al,%al
  801ae3:	74 04                	je     801ae9 <strcmp+0x1c>
  801ae5:	3a 02                	cmp    (%edx),%al
  801ae7:	74 ef                	je     801ad8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ae9:	0f b6 c0             	movzbl %al,%eax
  801aec:	0f b6 12             	movzbl (%edx),%edx
  801aef:	29 d0                	sub    %edx,%eax
}
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    

00801af3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	53                   	push   %ebx
  801af7:	8b 45 08             	mov    0x8(%ebp),%eax
  801afa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801afd:	89 c3                	mov    %eax,%ebx
  801aff:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801b02:	eb 06                	jmp    801b0a <strncmp+0x17>
		n--, p++, q++;
  801b04:	83 c0 01             	add    $0x1,%eax
  801b07:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b0a:	39 d8                	cmp    %ebx,%eax
  801b0c:	74 15                	je     801b23 <strncmp+0x30>
  801b0e:	0f b6 08             	movzbl (%eax),%ecx
  801b11:	84 c9                	test   %cl,%cl
  801b13:	74 04                	je     801b19 <strncmp+0x26>
  801b15:	3a 0a                	cmp    (%edx),%cl
  801b17:	74 eb                	je     801b04 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b19:	0f b6 00             	movzbl (%eax),%eax
  801b1c:	0f b6 12             	movzbl (%edx),%edx
  801b1f:	29 d0                	sub    %edx,%eax
  801b21:	eb 05                	jmp    801b28 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b23:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b28:	5b                   	pop    %ebx
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b35:	eb 07                	jmp    801b3e <strchr+0x13>
		if (*s == c)
  801b37:	38 ca                	cmp    %cl,%dl
  801b39:	74 0f                	je     801b4a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b3b:	83 c0 01             	add    $0x1,%eax
  801b3e:	0f b6 10             	movzbl (%eax),%edx
  801b41:	84 d2                	test   %dl,%dl
  801b43:	75 f2                	jne    801b37 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b52:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b56:	eb 03                	jmp    801b5b <strfind+0xf>
  801b58:	83 c0 01             	add    $0x1,%eax
  801b5b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b5e:	38 ca                	cmp    %cl,%dl
  801b60:	74 04                	je     801b66 <strfind+0x1a>
  801b62:	84 d2                	test   %dl,%dl
  801b64:	75 f2                	jne    801b58 <strfind+0xc>
			break;
	return (char *) s;
}
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    

00801b68 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	57                   	push   %edi
  801b6c:	56                   	push   %esi
  801b6d:	53                   	push   %ebx
  801b6e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b71:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b74:	85 c9                	test   %ecx,%ecx
  801b76:	74 36                	je     801bae <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b78:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b7e:	75 28                	jne    801ba8 <memset+0x40>
  801b80:	f6 c1 03             	test   $0x3,%cl
  801b83:	75 23                	jne    801ba8 <memset+0x40>
		c &= 0xFF;
  801b85:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b89:	89 d3                	mov    %edx,%ebx
  801b8b:	c1 e3 08             	shl    $0x8,%ebx
  801b8e:	89 d6                	mov    %edx,%esi
  801b90:	c1 e6 18             	shl    $0x18,%esi
  801b93:	89 d0                	mov    %edx,%eax
  801b95:	c1 e0 10             	shl    $0x10,%eax
  801b98:	09 f0                	or     %esi,%eax
  801b9a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b9c:	89 d8                	mov    %ebx,%eax
  801b9e:	09 d0                	or     %edx,%eax
  801ba0:	c1 e9 02             	shr    $0x2,%ecx
  801ba3:	fc                   	cld    
  801ba4:	f3 ab                	rep stos %eax,%es:(%edi)
  801ba6:	eb 06                	jmp    801bae <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bab:	fc                   	cld    
  801bac:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801bae:	89 f8                	mov    %edi,%eax
  801bb0:	5b                   	pop    %ebx
  801bb1:	5e                   	pop    %esi
  801bb2:	5f                   	pop    %edi
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    

00801bb5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	57                   	push   %edi
  801bb9:	56                   	push   %esi
  801bba:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801bc3:	39 c6                	cmp    %eax,%esi
  801bc5:	73 35                	jae    801bfc <memmove+0x47>
  801bc7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801bca:	39 d0                	cmp    %edx,%eax
  801bcc:	73 2e                	jae    801bfc <memmove+0x47>
		s += n;
		d += n;
  801bce:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bd1:	89 d6                	mov    %edx,%esi
  801bd3:	09 fe                	or     %edi,%esi
  801bd5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801bdb:	75 13                	jne    801bf0 <memmove+0x3b>
  801bdd:	f6 c1 03             	test   $0x3,%cl
  801be0:	75 0e                	jne    801bf0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801be2:	83 ef 04             	sub    $0x4,%edi
  801be5:	8d 72 fc             	lea    -0x4(%edx),%esi
  801be8:	c1 e9 02             	shr    $0x2,%ecx
  801beb:	fd                   	std    
  801bec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bee:	eb 09                	jmp    801bf9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bf0:	83 ef 01             	sub    $0x1,%edi
  801bf3:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bf6:	fd                   	std    
  801bf7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bf9:	fc                   	cld    
  801bfa:	eb 1d                	jmp    801c19 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bfc:	89 f2                	mov    %esi,%edx
  801bfe:	09 c2                	or     %eax,%edx
  801c00:	f6 c2 03             	test   $0x3,%dl
  801c03:	75 0f                	jne    801c14 <memmove+0x5f>
  801c05:	f6 c1 03             	test   $0x3,%cl
  801c08:	75 0a                	jne    801c14 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801c0a:	c1 e9 02             	shr    $0x2,%ecx
  801c0d:	89 c7                	mov    %eax,%edi
  801c0f:	fc                   	cld    
  801c10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c12:	eb 05                	jmp    801c19 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c14:	89 c7                	mov    %eax,%edi
  801c16:	fc                   	cld    
  801c17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c19:	5e                   	pop    %esi
  801c1a:	5f                   	pop    %edi
  801c1b:	5d                   	pop    %ebp
  801c1c:	c3                   	ret    

00801c1d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c20:	ff 75 10             	pushl  0x10(%ebp)
  801c23:	ff 75 0c             	pushl  0xc(%ebp)
  801c26:	ff 75 08             	pushl  0x8(%ebp)
  801c29:	e8 87 ff ff ff       	call   801bb5 <memmove>
}
  801c2e:	c9                   	leave  
  801c2f:	c3                   	ret    

00801c30 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	56                   	push   %esi
  801c34:	53                   	push   %ebx
  801c35:	8b 45 08             	mov    0x8(%ebp),%eax
  801c38:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c3b:	89 c6                	mov    %eax,%esi
  801c3d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c40:	eb 1a                	jmp    801c5c <memcmp+0x2c>
		if (*s1 != *s2)
  801c42:	0f b6 08             	movzbl (%eax),%ecx
  801c45:	0f b6 1a             	movzbl (%edx),%ebx
  801c48:	38 d9                	cmp    %bl,%cl
  801c4a:	74 0a                	je     801c56 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c4c:	0f b6 c1             	movzbl %cl,%eax
  801c4f:	0f b6 db             	movzbl %bl,%ebx
  801c52:	29 d8                	sub    %ebx,%eax
  801c54:	eb 0f                	jmp    801c65 <memcmp+0x35>
		s1++, s2++;
  801c56:	83 c0 01             	add    $0x1,%eax
  801c59:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c5c:	39 f0                	cmp    %esi,%eax
  801c5e:	75 e2                	jne    801c42 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c65:	5b                   	pop    %ebx
  801c66:	5e                   	pop    %esi
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    

00801c69 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	53                   	push   %ebx
  801c6d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c70:	89 c1                	mov    %eax,%ecx
  801c72:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c75:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c79:	eb 0a                	jmp    801c85 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c7b:	0f b6 10             	movzbl (%eax),%edx
  801c7e:	39 da                	cmp    %ebx,%edx
  801c80:	74 07                	je     801c89 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c82:	83 c0 01             	add    $0x1,%eax
  801c85:	39 c8                	cmp    %ecx,%eax
  801c87:	72 f2                	jb     801c7b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c89:	5b                   	pop    %ebx
  801c8a:	5d                   	pop    %ebp
  801c8b:	c3                   	ret    

00801c8c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	57                   	push   %edi
  801c90:	56                   	push   %esi
  801c91:	53                   	push   %ebx
  801c92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c98:	eb 03                	jmp    801c9d <strtol+0x11>
		s++;
  801c9a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c9d:	0f b6 01             	movzbl (%ecx),%eax
  801ca0:	3c 20                	cmp    $0x20,%al
  801ca2:	74 f6                	je     801c9a <strtol+0xe>
  801ca4:	3c 09                	cmp    $0x9,%al
  801ca6:	74 f2                	je     801c9a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ca8:	3c 2b                	cmp    $0x2b,%al
  801caa:	75 0a                	jne    801cb6 <strtol+0x2a>
		s++;
  801cac:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801caf:	bf 00 00 00 00       	mov    $0x0,%edi
  801cb4:	eb 11                	jmp    801cc7 <strtol+0x3b>
  801cb6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801cbb:	3c 2d                	cmp    $0x2d,%al
  801cbd:	75 08                	jne    801cc7 <strtol+0x3b>
		s++, neg = 1;
  801cbf:	83 c1 01             	add    $0x1,%ecx
  801cc2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801cc7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ccd:	75 15                	jne    801ce4 <strtol+0x58>
  801ccf:	80 39 30             	cmpb   $0x30,(%ecx)
  801cd2:	75 10                	jne    801ce4 <strtol+0x58>
  801cd4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801cd8:	75 7c                	jne    801d56 <strtol+0xca>
		s += 2, base = 16;
  801cda:	83 c1 02             	add    $0x2,%ecx
  801cdd:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ce2:	eb 16                	jmp    801cfa <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ce4:	85 db                	test   %ebx,%ebx
  801ce6:	75 12                	jne    801cfa <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ce8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ced:	80 39 30             	cmpb   $0x30,(%ecx)
  801cf0:	75 08                	jne    801cfa <strtol+0x6e>
		s++, base = 8;
  801cf2:	83 c1 01             	add    $0x1,%ecx
  801cf5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cfa:	b8 00 00 00 00       	mov    $0x0,%eax
  801cff:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801d02:	0f b6 11             	movzbl (%ecx),%edx
  801d05:	8d 72 d0             	lea    -0x30(%edx),%esi
  801d08:	89 f3                	mov    %esi,%ebx
  801d0a:	80 fb 09             	cmp    $0x9,%bl
  801d0d:	77 08                	ja     801d17 <strtol+0x8b>
			dig = *s - '0';
  801d0f:	0f be d2             	movsbl %dl,%edx
  801d12:	83 ea 30             	sub    $0x30,%edx
  801d15:	eb 22                	jmp    801d39 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801d17:	8d 72 9f             	lea    -0x61(%edx),%esi
  801d1a:	89 f3                	mov    %esi,%ebx
  801d1c:	80 fb 19             	cmp    $0x19,%bl
  801d1f:	77 08                	ja     801d29 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d21:	0f be d2             	movsbl %dl,%edx
  801d24:	83 ea 57             	sub    $0x57,%edx
  801d27:	eb 10                	jmp    801d39 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d29:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d2c:	89 f3                	mov    %esi,%ebx
  801d2e:	80 fb 19             	cmp    $0x19,%bl
  801d31:	77 16                	ja     801d49 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d33:	0f be d2             	movsbl %dl,%edx
  801d36:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d39:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d3c:	7d 0b                	jge    801d49 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d3e:	83 c1 01             	add    $0x1,%ecx
  801d41:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d45:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d47:	eb b9                	jmp    801d02 <strtol+0x76>

	if (endptr)
  801d49:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d4d:	74 0d                	je     801d5c <strtol+0xd0>
		*endptr = (char *) s;
  801d4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d52:	89 0e                	mov    %ecx,(%esi)
  801d54:	eb 06                	jmp    801d5c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d56:	85 db                	test   %ebx,%ebx
  801d58:	74 98                	je     801cf2 <strtol+0x66>
  801d5a:	eb 9e                	jmp    801cfa <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d5c:	89 c2                	mov    %eax,%edx
  801d5e:	f7 da                	neg    %edx
  801d60:	85 ff                	test   %edi,%edi
  801d62:	0f 45 c2             	cmovne %edx,%eax
}
  801d65:	5b                   	pop    %ebx
  801d66:	5e                   	pop    %esi
  801d67:	5f                   	pop    %edi
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    

00801d6a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d70:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d77:	75 2a                	jne    801da3 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d79:	83 ec 04             	sub    $0x4,%esp
  801d7c:	6a 07                	push   $0x7
  801d7e:	68 00 f0 bf ee       	push   $0xeebff000
  801d83:	6a 00                	push   $0x0
  801d85:	e8 0a e4 ff ff       	call   800194 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	79 12                	jns    801da3 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d91:	50                   	push   %eax
  801d92:	68 80 26 80 00       	push   $0x802680
  801d97:	6a 23                	push   $0x23
  801d99:	68 84 26 80 00       	push   $0x802684
  801d9e:	e8 22 f6 ff ff       	call   8013c5 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801da3:	8b 45 08             	mov    0x8(%ebp),%eax
  801da6:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801dab:	83 ec 08             	sub    $0x8,%esp
  801dae:	68 c5 03 80 00       	push   $0x8003c5
  801db3:	6a 00                	push   $0x0
  801db5:	e8 25 e5 ff ff       	call   8002df <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801dba:	83 c4 10             	add    $0x10,%esp
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	79 12                	jns    801dd3 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801dc1:	50                   	push   %eax
  801dc2:	68 80 26 80 00       	push   $0x802680
  801dc7:	6a 2c                	push   $0x2c
  801dc9:	68 84 26 80 00       	push   $0x802684
  801dce:	e8 f2 f5 ff ff       	call   8013c5 <_panic>
	}
}
  801dd3:	c9                   	leave  
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
  801def:	e8 50 e5 ff ff       	call   800344 <sys_ipc_recv>
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	eb 0c                	jmp    801e05 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801df9:	83 ec 0c             	sub    $0xc,%esp
  801dfc:	50                   	push   %eax
  801dfd:	e8 42 e5 ff ff       	call   800344 <sys_ipc_recv>
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
  801e1a:	75 2a                	jne    801e46 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e1c:	85 f6                	test   %esi,%esi
  801e1e:	74 0d                	je     801e2d <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e20:	a1 04 40 80 00       	mov    0x804004,%eax
  801e25:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e2b:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e2d:	85 db                	test   %ebx,%ebx
  801e2f:	74 0d                	je     801e3e <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e31:	a1 04 40 80 00       	mov    0x804004,%eax
  801e36:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e3c:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e3e:	a1 04 40 80 00       	mov    0x804004,%eax
  801e43:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801e46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e49:	5b                   	pop    %ebx
  801e4a:	5e                   	pop    %esi
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    

00801e4d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	57                   	push   %edi
  801e51:	56                   	push   %esi
  801e52:	53                   	push   %ebx
  801e53:	83 ec 0c             	sub    $0xc,%esp
  801e56:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e59:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e5f:	85 db                	test   %ebx,%ebx
  801e61:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e66:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e69:	ff 75 14             	pushl  0x14(%ebp)
  801e6c:	53                   	push   %ebx
  801e6d:	56                   	push   %esi
  801e6e:	57                   	push   %edi
  801e6f:	e8 ad e4 ff ff       	call   800321 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e74:	89 c2                	mov    %eax,%edx
  801e76:	c1 ea 1f             	shr    $0x1f,%edx
  801e79:	83 c4 10             	add    $0x10,%esp
  801e7c:	84 d2                	test   %dl,%dl
  801e7e:	74 17                	je     801e97 <ipc_send+0x4a>
  801e80:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e83:	74 12                	je     801e97 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e85:	50                   	push   %eax
  801e86:	68 92 26 80 00       	push   $0x802692
  801e8b:	6a 47                	push   $0x47
  801e8d:	68 a0 26 80 00       	push   $0x8026a0
  801e92:	e8 2e f5 ff ff       	call   8013c5 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e97:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e9a:	75 07                	jne    801ea3 <ipc_send+0x56>
			sys_yield();
  801e9c:	e8 d4 e2 ff ff       	call   800175 <sys_yield>
  801ea1:	eb c6                	jmp    801e69 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	75 c2                	jne    801e69 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ea7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eaa:	5b                   	pop    %ebx
  801eab:	5e                   	pop    %esi
  801eac:	5f                   	pop    %edi
  801ead:	5d                   	pop    %ebp
  801eae:	c3                   	ret    

00801eaf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eb5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eba:	89 c2                	mov    %eax,%edx
  801ebc:	c1 e2 07             	shl    $0x7,%edx
  801ebf:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801ec6:	8b 52 5c             	mov    0x5c(%edx),%edx
  801ec9:	39 ca                	cmp    %ecx,%edx
  801ecb:	75 11                	jne    801ede <ipc_find_env+0x2f>
			return envs[i].env_id;
  801ecd:	89 c2                	mov    %eax,%edx
  801ecf:	c1 e2 07             	shl    $0x7,%edx
  801ed2:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801ed9:	8b 40 54             	mov    0x54(%eax),%eax
  801edc:	eb 0f                	jmp    801eed <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ede:	83 c0 01             	add    $0x1,%eax
  801ee1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ee6:	75 d2                	jne    801eba <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ee8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eed:	5d                   	pop    %ebp
  801eee:	c3                   	ret    

00801eef <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef5:	89 d0                	mov    %edx,%eax
  801ef7:	c1 e8 16             	shr    $0x16,%eax
  801efa:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f01:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f06:	f6 c1 01             	test   $0x1,%cl
  801f09:	74 1d                	je     801f28 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f0b:	c1 ea 0c             	shr    $0xc,%edx
  801f0e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f15:	f6 c2 01             	test   $0x1,%dl
  801f18:	74 0e                	je     801f28 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f1a:	c1 ea 0c             	shr    $0xc,%edx
  801f1d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f24:	ef 
  801f25:	0f b7 c0             	movzwl %ax,%eax
}
  801f28:	5d                   	pop    %ebp
  801f29:	c3                   	ret    
  801f2a:	66 90                	xchg   %ax,%ax
  801f2c:	66 90                	xchg   %ax,%ax
  801f2e:	66 90                	xchg   %ax,%ax

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
