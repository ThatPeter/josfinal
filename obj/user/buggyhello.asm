
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 89 00 00 00       	call   8000cb <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 f2 00 00 00       	call   800149 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	89 c2                	mov    %eax,%edx
  80005e:	c1 e2 07             	shl    $0x7,%edx
  800061:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800068:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 db                	test   %ebx,%ebx
  80006f:	7e 07                	jle    800078 <libmain+0x31>
		binaryname = argv[0];
  800071:	8b 06                	mov    (%esi),%eax
  800073:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800078:	83 ec 08             	sub    $0x8,%esp
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	e8 b1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800082:	e8 2a 00 00 00       	call   8000b1 <exit>
}
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008d:	5b                   	pop    %ebx
  80008e:	5e                   	pop    %esi
  80008f:	5d                   	pop    %ebp
  800090:	c3                   	ret    

00800091 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800097:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  80009c:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80009e:	e8 a6 00 00 00       	call   800149 <sys_getenvid>
  8000a3:	83 ec 0c             	sub    $0xc,%esp
  8000a6:	50                   	push   %eax
  8000a7:	e8 ec 02 00 00       	call   800398 <sys_thread_free>
}
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    

008000b1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b7:	e8 b9 07 00 00       	call   800875 <close_all>
	sys_env_destroy(0);
  8000bc:	83 ec 0c             	sub    $0xc,%esp
  8000bf:	6a 00                	push   $0x0
  8000c1:	e8 42 00 00 00       	call   800108 <sys_env_destroy>
}
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    

008000cb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	57                   	push   %edi
  8000cf:	56                   	push   %esi
  8000d0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000dc:	89 c3                	mov    %eax,%ebx
  8000de:	89 c7                	mov    %eax,%edi
  8000e0:	89 c6                	mov    %eax,%esi
  8000e2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f9:	89 d1                	mov    %edx,%ecx
  8000fb:	89 d3                	mov    %edx,%ebx
  8000fd:	89 d7                	mov    %edx,%edi
  8000ff:	89 d6                	mov    %edx,%esi
  800101:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5f                   	pop    %edi
  800106:	5d                   	pop    %ebp
  800107:	c3                   	ret    

00800108 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	57                   	push   %edi
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800111:	b9 00 00 00 00       	mov    $0x0,%ecx
  800116:	b8 03 00 00 00       	mov    $0x3,%eax
  80011b:	8b 55 08             	mov    0x8(%ebp),%edx
  80011e:	89 cb                	mov    %ecx,%ebx
  800120:	89 cf                	mov    %ecx,%edi
  800122:	89 ce                	mov    %ecx,%esi
  800124:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800126:	85 c0                	test   %eax,%eax
  800128:	7e 17                	jle    800141 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012a:	83 ec 0c             	sub    $0xc,%esp
  80012d:	50                   	push   %eax
  80012e:	6a 03                	push   $0x3
  800130:	68 ca 21 80 00       	push   $0x8021ca
  800135:	6a 23                	push   $0x23
  800137:	68 e7 21 80 00       	push   $0x8021e7
  80013c:	e8 53 12 00 00       	call   801394 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800141:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 02 00 00 00       	mov    $0x2,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_yield>:

void
sys_yield(void)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016e:	ba 00 00 00 00       	mov    $0x0,%edx
  800173:	b8 0b 00 00 00       	mov    $0xb,%eax
  800178:	89 d1                	mov    %edx,%ecx
  80017a:	89 d3                	mov    %edx,%ebx
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	89 d6                	mov    %edx,%esi
  800180:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800182:	5b                   	pop    %ebx
  800183:	5e                   	pop    %esi
  800184:	5f                   	pop    %edi
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    

00800187 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800190:	be 00 00 00 00       	mov    $0x0,%esi
  800195:	b8 04 00 00 00       	mov    $0x4,%eax
  80019a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019d:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a3:	89 f7                	mov    %esi,%edi
  8001a5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	7e 17                	jle    8001c2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	50                   	push   %eax
  8001af:	6a 04                	push   $0x4
  8001b1:	68 ca 21 80 00       	push   $0x8021ca
  8001b6:	6a 23                	push   $0x23
  8001b8:	68 e7 21 80 00       	push   $0x8021e7
  8001bd:	e8 d2 11 00 00       	call   801394 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c5:	5b                   	pop    %ebx
  8001c6:	5e                   	pop    %esi
  8001c7:	5f                   	pop    %edi
  8001c8:	5d                   	pop    %ebp
  8001c9:	c3                   	ret    

008001ca <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	57                   	push   %edi
  8001ce:	56                   	push   %esi
  8001cf:	53                   	push   %ebx
  8001d0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001db:	8b 55 08             	mov    0x8(%ebp),%edx
  8001de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e4:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e9:	85 c0                	test   %eax,%eax
  8001eb:	7e 17                	jle    800204 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ed:	83 ec 0c             	sub    $0xc,%esp
  8001f0:	50                   	push   %eax
  8001f1:	6a 05                	push   $0x5
  8001f3:	68 ca 21 80 00       	push   $0x8021ca
  8001f8:	6a 23                	push   $0x23
  8001fa:	68 e7 21 80 00       	push   $0x8021e7
  8001ff:	e8 90 11 00 00       	call   801394 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800204:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	5f                   	pop    %edi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    

0080020c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800215:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021a:	b8 06 00 00 00       	mov    $0x6,%eax
  80021f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800222:	8b 55 08             	mov    0x8(%ebp),%edx
  800225:	89 df                	mov    %ebx,%edi
  800227:	89 de                	mov    %ebx,%esi
  800229:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80022b:	85 c0                	test   %eax,%eax
  80022d:	7e 17                	jle    800246 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022f:	83 ec 0c             	sub    $0xc,%esp
  800232:	50                   	push   %eax
  800233:	6a 06                	push   $0x6
  800235:	68 ca 21 80 00       	push   $0x8021ca
  80023a:	6a 23                	push   $0x23
  80023c:	68 e7 21 80 00       	push   $0x8021e7
  800241:	e8 4e 11 00 00       	call   801394 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800246:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800249:	5b                   	pop    %ebx
  80024a:	5e                   	pop    %esi
  80024b:	5f                   	pop    %edi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	57                   	push   %edi
  800252:	56                   	push   %esi
  800253:	53                   	push   %ebx
  800254:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800257:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025c:	b8 08 00 00 00       	mov    $0x8,%eax
  800261:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800264:	8b 55 08             	mov    0x8(%ebp),%edx
  800267:	89 df                	mov    %ebx,%edi
  800269:	89 de                	mov    %ebx,%esi
  80026b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80026d:	85 c0                	test   %eax,%eax
  80026f:	7e 17                	jle    800288 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800271:	83 ec 0c             	sub    $0xc,%esp
  800274:	50                   	push   %eax
  800275:	6a 08                	push   $0x8
  800277:	68 ca 21 80 00       	push   $0x8021ca
  80027c:	6a 23                	push   $0x23
  80027e:	68 e7 21 80 00       	push   $0x8021e7
  800283:	e8 0c 11 00 00       	call   801394 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800288:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028b:	5b                   	pop    %ebx
  80028c:	5e                   	pop    %esi
  80028d:	5f                   	pop    %edi
  80028e:	5d                   	pop    %ebp
  80028f:	c3                   	ret    

00800290 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800299:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029e:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a9:	89 df                	mov    %ebx,%edi
  8002ab:	89 de                	mov    %ebx,%esi
  8002ad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	7e 17                	jle    8002ca <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b3:	83 ec 0c             	sub    $0xc,%esp
  8002b6:	50                   	push   %eax
  8002b7:	6a 09                	push   $0x9
  8002b9:	68 ca 21 80 00       	push   $0x8021ca
  8002be:	6a 23                	push   $0x23
  8002c0:	68 e7 21 80 00       	push   $0x8021e7
  8002c5:	e8 ca 10 00 00       	call   801394 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cd:	5b                   	pop    %ebx
  8002ce:	5e                   	pop    %esi
  8002cf:	5f                   	pop    %edi
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002eb:	89 df                	mov    %ebx,%edi
  8002ed:	89 de                	mov    %ebx,%esi
  8002ef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	7e 17                	jle    80030c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	50                   	push   %eax
  8002f9:	6a 0a                	push   $0xa
  8002fb:	68 ca 21 80 00       	push   $0x8021ca
  800300:	6a 23                	push   $0x23
  800302:	68 e7 21 80 00       	push   $0x8021e7
  800307:	e8 88 10 00 00       	call   801394 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80030c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030f:	5b                   	pop    %ebx
  800310:	5e                   	pop    %esi
  800311:	5f                   	pop    %edi
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031a:	be 00 00 00 00       	mov    $0x0,%esi
  80031f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800324:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800327:	8b 55 08             	mov    0x8(%ebp),%edx
  80032a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800330:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800332:	5b                   	pop    %ebx
  800333:	5e                   	pop    %esi
  800334:	5f                   	pop    %edi
  800335:	5d                   	pop    %ebp
  800336:	c3                   	ret    

00800337 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	57                   	push   %edi
  80033b:	56                   	push   %esi
  80033c:	53                   	push   %ebx
  80033d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800340:	b9 00 00 00 00       	mov    $0x0,%ecx
  800345:	b8 0d 00 00 00       	mov    $0xd,%eax
  80034a:	8b 55 08             	mov    0x8(%ebp),%edx
  80034d:	89 cb                	mov    %ecx,%ebx
  80034f:	89 cf                	mov    %ecx,%edi
  800351:	89 ce                	mov    %ecx,%esi
  800353:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800355:	85 c0                	test   %eax,%eax
  800357:	7e 17                	jle    800370 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800359:	83 ec 0c             	sub    $0xc,%esp
  80035c:	50                   	push   %eax
  80035d:	6a 0d                	push   $0xd
  80035f:	68 ca 21 80 00       	push   $0x8021ca
  800364:	6a 23                	push   $0x23
  800366:	68 e7 21 80 00       	push   $0x8021e7
  80036b:	e8 24 10 00 00       	call   801394 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800370:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800373:	5b                   	pop    %ebx
  800374:	5e                   	pop    %esi
  800375:	5f                   	pop    %edi
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	57                   	push   %edi
  80037c:	56                   	push   %esi
  80037d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800383:	b8 0e 00 00 00       	mov    $0xe,%eax
  800388:	8b 55 08             	mov    0x8(%ebp),%edx
  80038b:	89 cb                	mov    %ecx,%ebx
  80038d:	89 cf                	mov    %ecx,%edi
  80038f:	89 ce                	mov    %ecx,%esi
  800391:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800393:	5b                   	pop    %ebx
  800394:	5e                   	pop    %esi
  800395:	5f                   	pop    %edi
  800396:	5d                   	pop    %ebp
  800397:	c3                   	ret    

00800398 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	57                   	push   %edi
  80039c:	56                   	push   %esi
  80039d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a3:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ab:	89 cb                	mov    %ecx,%ebx
  8003ad:	89 cf                	mov    %ecx,%edi
  8003af:	89 ce                	mov    %ecx,%esi
  8003b1:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003b3:	5b                   	pop    %ebx
  8003b4:	5e                   	pop    %esi
  8003b5:	5f                   	pop    %edi
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	53                   	push   %ebx
  8003bc:	83 ec 04             	sub    $0x4,%esp
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003c2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003c4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003c8:	74 11                	je     8003db <pgfault+0x23>
  8003ca:	89 d8                	mov    %ebx,%eax
  8003cc:	c1 e8 0c             	shr    $0xc,%eax
  8003cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003d6:	f6 c4 08             	test   $0x8,%ah
  8003d9:	75 14                	jne    8003ef <pgfault+0x37>
		panic("faulting access");
  8003db:	83 ec 04             	sub    $0x4,%esp
  8003de:	68 f5 21 80 00       	push   $0x8021f5
  8003e3:	6a 1e                	push   $0x1e
  8003e5:	68 05 22 80 00       	push   $0x802205
  8003ea:	e8 a5 0f 00 00       	call   801394 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8003ef:	83 ec 04             	sub    $0x4,%esp
  8003f2:	6a 07                	push   $0x7
  8003f4:	68 00 f0 7f 00       	push   $0x7ff000
  8003f9:	6a 00                	push   $0x0
  8003fb:	e8 87 fd ff ff       	call   800187 <sys_page_alloc>
	if (r < 0) {
  800400:	83 c4 10             	add    $0x10,%esp
  800403:	85 c0                	test   %eax,%eax
  800405:	79 12                	jns    800419 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800407:	50                   	push   %eax
  800408:	68 10 22 80 00       	push   $0x802210
  80040d:	6a 2c                	push   $0x2c
  80040f:	68 05 22 80 00       	push   $0x802205
  800414:	e8 7b 0f 00 00       	call   801394 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800419:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80041f:	83 ec 04             	sub    $0x4,%esp
  800422:	68 00 10 00 00       	push   $0x1000
  800427:	53                   	push   %ebx
  800428:	68 00 f0 7f 00       	push   $0x7ff000
  80042d:	e8 ba 17 00 00       	call   801bec <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800432:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800439:	53                   	push   %ebx
  80043a:	6a 00                	push   $0x0
  80043c:	68 00 f0 7f 00       	push   $0x7ff000
  800441:	6a 00                	push   $0x0
  800443:	e8 82 fd ff ff       	call   8001ca <sys_page_map>
	if (r < 0) {
  800448:	83 c4 20             	add    $0x20,%esp
  80044b:	85 c0                	test   %eax,%eax
  80044d:	79 12                	jns    800461 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80044f:	50                   	push   %eax
  800450:	68 10 22 80 00       	push   $0x802210
  800455:	6a 33                	push   $0x33
  800457:	68 05 22 80 00       	push   $0x802205
  80045c:	e8 33 0f 00 00       	call   801394 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	68 00 f0 7f 00       	push   $0x7ff000
  800469:	6a 00                	push   $0x0
  80046b:	e8 9c fd ff ff       	call   80020c <sys_page_unmap>
	if (r < 0) {
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	85 c0                	test   %eax,%eax
  800475:	79 12                	jns    800489 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800477:	50                   	push   %eax
  800478:	68 10 22 80 00       	push   $0x802210
  80047d:	6a 37                	push   $0x37
  80047f:	68 05 22 80 00       	push   $0x802205
  800484:	e8 0b 0f 00 00       	call   801394 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800489:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80048c:	c9                   	leave  
  80048d:	c3                   	ret    

0080048e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80048e:	55                   	push   %ebp
  80048f:	89 e5                	mov    %esp,%ebp
  800491:	57                   	push   %edi
  800492:	56                   	push   %esi
  800493:	53                   	push   %ebx
  800494:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800497:	68 b8 03 80 00       	push   $0x8003b8
  80049c:	e8 98 18 00 00       	call   801d39 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004a1:	b8 07 00 00 00       	mov    $0x7,%eax
  8004a6:	cd 30                	int    $0x30
  8004a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	85 c0                	test   %eax,%eax
  8004b0:	79 17                	jns    8004c9 <fork+0x3b>
		panic("fork fault %e");
  8004b2:	83 ec 04             	sub    $0x4,%esp
  8004b5:	68 29 22 80 00       	push   $0x802229
  8004ba:	68 84 00 00 00       	push   $0x84
  8004bf:	68 05 22 80 00       	push   $0x802205
  8004c4:	e8 cb 0e 00 00       	call   801394 <_panic>
  8004c9:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004cf:	75 25                	jne    8004f6 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004d1:	e8 73 fc ff ff       	call   800149 <sys_getenvid>
  8004d6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004db:	89 c2                	mov    %eax,%edx
  8004dd:	c1 e2 07             	shl    $0x7,%edx
  8004e0:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8004e7:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f1:	e9 61 01 00 00       	jmp    800657 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8004f6:	83 ec 04             	sub    $0x4,%esp
  8004f9:	6a 07                	push   $0x7
  8004fb:	68 00 f0 bf ee       	push   $0xeebff000
  800500:	ff 75 e4             	pushl  -0x1c(%ebp)
  800503:	e8 7f fc ff ff       	call   800187 <sys_page_alloc>
  800508:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80050b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800510:	89 d8                	mov    %ebx,%eax
  800512:	c1 e8 16             	shr    $0x16,%eax
  800515:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80051c:	a8 01                	test   $0x1,%al
  80051e:	0f 84 fc 00 00 00    	je     800620 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800524:	89 d8                	mov    %ebx,%eax
  800526:	c1 e8 0c             	shr    $0xc,%eax
  800529:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800530:	f6 c2 01             	test   $0x1,%dl
  800533:	0f 84 e7 00 00 00    	je     800620 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800539:	89 c6                	mov    %eax,%esi
  80053b:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80053e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800545:	f6 c6 04             	test   $0x4,%dh
  800548:	74 39                	je     800583 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80054a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	25 07 0e 00 00       	and    $0xe07,%eax
  800559:	50                   	push   %eax
  80055a:	56                   	push   %esi
  80055b:	57                   	push   %edi
  80055c:	56                   	push   %esi
  80055d:	6a 00                	push   $0x0
  80055f:	e8 66 fc ff ff       	call   8001ca <sys_page_map>
		if (r < 0) {
  800564:	83 c4 20             	add    $0x20,%esp
  800567:	85 c0                	test   %eax,%eax
  800569:	0f 89 b1 00 00 00    	jns    800620 <fork+0x192>
		    	panic("sys page map fault %e");
  80056f:	83 ec 04             	sub    $0x4,%esp
  800572:	68 37 22 80 00       	push   $0x802237
  800577:	6a 54                	push   $0x54
  800579:	68 05 22 80 00       	push   $0x802205
  80057e:	e8 11 0e 00 00       	call   801394 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800583:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80058a:	f6 c2 02             	test   $0x2,%dl
  80058d:	75 0c                	jne    80059b <fork+0x10d>
  80058f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800596:	f6 c4 08             	test   $0x8,%ah
  800599:	74 5b                	je     8005f6 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80059b:	83 ec 0c             	sub    $0xc,%esp
  80059e:	68 05 08 00 00       	push   $0x805
  8005a3:	56                   	push   %esi
  8005a4:	57                   	push   %edi
  8005a5:	56                   	push   %esi
  8005a6:	6a 00                	push   $0x0
  8005a8:	e8 1d fc ff ff       	call   8001ca <sys_page_map>
		if (r < 0) {
  8005ad:	83 c4 20             	add    $0x20,%esp
  8005b0:	85 c0                	test   %eax,%eax
  8005b2:	79 14                	jns    8005c8 <fork+0x13a>
		    	panic("sys page map fault %e");
  8005b4:	83 ec 04             	sub    $0x4,%esp
  8005b7:	68 37 22 80 00       	push   $0x802237
  8005bc:	6a 5b                	push   $0x5b
  8005be:	68 05 22 80 00       	push   $0x802205
  8005c3:	e8 cc 0d 00 00       	call   801394 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005c8:	83 ec 0c             	sub    $0xc,%esp
  8005cb:	68 05 08 00 00       	push   $0x805
  8005d0:	56                   	push   %esi
  8005d1:	6a 00                	push   $0x0
  8005d3:	56                   	push   %esi
  8005d4:	6a 00                	push   $0x0
  8005d6:	e8 ef fb ff ff       	call   8001ca <sys_page_map>
		if (r < 0) {
  8005db:	83 c4 20             	add    $0x20,%esp
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	79 3e                	jns    800620 <fork+0x192>
		    	panic("sys page map fault %e");
  8005e2:	83 ec 04             	sub    $0x4,%esp
  8005e5:	68 37 22 80 00       	push   $0x802237
  8005ea:	6a 5f                	push   $0x5f
  8005ec:	68 05 22 80 00       	push   $0x802205
  8005f1:	e8 9e 0d 00 00       	call   801394 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8005f6:	83 ec 0c             	sub    $0xc,%esp
  8005f9:	6a 05                	push   $0x5
  8005fb:	56                   	push   %esi
  8005fc:	57                   	push   %edi
  8005fd:	56                   	push   %esi
  8005fe:	6a 00                	push   $0x0
  800600:	e8 c5 fb ff ff       	call   8001ca <sys_page_map>
		if (r < 0) {
  800605:	83 c4 20             	add    $0x20,%esp
  800608:	85 c0                	test   %eax,%eax
  80060a:	79 14                	jns    800620 <fork+0x192>
		    	panic("sys page map fault %e");
  80060c:	83 ec 04             	sub    $0x4,%esp
  80060f:	68 37 22 80 00       	push   $0x802237
  800614:	6a 64                	push   $0x64
  800616:	68 05 22 80 00       	push   $0x802205
  80061b:	e8 74 0d 00 00       	call   801394 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800620:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800626:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80062c:	0f 85 de fe ff ff    	jne    800510 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800632:	a1 04 40 80 00       	mov    0x804004,%eax
  800637:	8b 40 70             	mov    0x70(%eax),%eax
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	50                   	push   %eax
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800641:	57                   	push   %edi
  800642:	e8 8b fc ff ff       	call   8002d2 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	6a 02                	push   $0x2
  80064c:	57                   	push   %edi
  80064d:	e8 fc fb ff ff       	call   80024e <sys_env_set_status>
	
	return envid;
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800657:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065a:	5b                   	pop    %ebx
  80065b:	5e                   	pop    %esi
  80065c:	5f                   	pop    %edi
  80065d:	5d                   	pop    %ebp
  80065e:	c3                   	ret    

0080065f <sfork>:

envid_t
sfork(void)
{
  80065f:	55                   	push   %ebp
  800660:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800662:	b8 00 00 00 00       	mov    $0x0,%eax
  800667:	5d                   	pop    %ebp
  800668:	c3                   	ret    

00800669 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800669:	55                   	push   %ebp
  80066a:	89 e5                	mov    %esp,%ebp
  80066c:	56                   	push   %esi
  80066d:	53                   	push   %ebx
  80066e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800671:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	53                   	push   %ebx
  80067b:	68 50 22 80 00       	push   $0x802250
  800680:	e8 e8 0d 00 00       	call   80146d <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800685:	c7 04 24 91 00 80 00 	movl   $0x800091,(%esp)
  80068c:	e8 e7 fc ff ff       	call   800378 <sys_thread_create>
  800691:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  800693:	83 c4 08             	add    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	68 50 22 80 00       	push   $0x802250
  80069c:	e8 cc 0d 00 00       	call   80146d <cprintf>
	return id;
	//return 0;
}
  8006a1:	89 f0                	mov    %esi,%eax
  8006a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006a6:	5b                   	pop    %ebx
  8006a7:	5e                   	pop    %esi
  8006a8:	5d                   	pop    %ebp
  8006a9:	c3                   	ret    

008006aa <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b0:	05 00 00 00 30       	add    $0x30000000,%eax
  8006b5:	c1 e8 0c             	shr    $0xc,%eax
}
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c0:	05 00 00 00 30       	add    $0x30000000,%eax
  8006c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006ca:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006cf:	5d                   	pop    %ebp
  8006d0:	c3                   	ret    

008006d1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006dc:	89 c2                	mov    %eax,%edx
  8006de:	c1 ea 16             	shr    $0x16,%edx
  8006e1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8006e8:	f6 c2 01             	test   $0x1,%dl
  8006eb:	74 11                	je     8006fe <fd_alloc+0x2d>
  8006ed:	89 c2                	mov    %eax,%edx
  8006ef:	c1 ea 0c             	shr    $0xc,%edx
  8006f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006f9:	f6 c2 01             	test   $0x1,%dl
  8006fc:	75 09                	jne    800707 <fd_alloc+0x36>
			*fd_store = fd;
  8006fe:	89 01                	mov    %eax,(%ecx)
			return 0;
  800700:	b8 00 00 00 00       	mov    $0x0,%eax
  800705:	eb 17                	jmp    80071e <fd_alloc+0x4d>
  800707:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80070c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800711:	75 c9                	jne    8006dc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800713:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800719:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80071e:	5d                   	pop    %ebp
  80071f:	c3                   	ret    

00800720 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800726:	83 f8 1f             	cmp    $0x1f,%eax
  800729:	77 36                	ja     800761 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80072b:	c1 e0 0c             	shl    $0xc,%eax
  80072e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800733:	89 c2                	mov    %eax,%edx
  800735:	c1 ea 16             	shr    $0x16,%edx
  800738:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80073f:	f6 c2 01             	test   $0x1,%dl
  800742:	74 24                	je     800768 <fd_lookup+0x48>
  800744:	89 c2                	mov    %eax,%edx
  800746:	c1 ea 0c             	shr    $0xc,%edx
  800749:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800750:	f6 c2 01             	test   $0x1,%dl
  800753:	74 1a                	je     80076f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800755:	8b 55 0c             	mov    0xc(%ebp),%edx
  800758:	89 02                	mov    %eax,(%edx)
	return 0;
  80075a:	b8 00 00 00 00       	mov    $0x0,%eax
  80075f:	eb 13                	jmp    800774 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800761:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800766:	eb 0c                	jmp    800774 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800768:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076d:	eb 05                	jmp    800774 <fd_lookup+0x54>
  80076f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	83 ec 08             	sub    $0x8,%esp
  80077c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077f:	ba f0 22 80 00       	mov    $0x8022f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800784:	eb 13                	jmp    800799 <dev_lookup+0x23>
  800786:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800789:	39 08                	cmp    %ecx,(%eax)
  80078b:	75 0c                	jne    800799 <dev_lookup+0x23>
			*dev = devtab[i];
  80078d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800790:	89 01                	mov    %eax,(%ecx)
			return 0;
  800792:	b8 00 00 00 00       	mov    $0x0,%eax
  800797:	eb 2e                	jmp    8007c7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800799:	8b 02                	mov    (%edx),%eax
  80079b:	85 c0                	test   %eax,%eax
  80079d:	75 e7                	jne    800786 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80079f:	a1 04 40 80 00       	mov    0x804004,%eax
  8007a4:	8b 40 54             	mov    0x54(%eax),%eax
  8007a7:	83 ec 04             	sub    $0x4,%esp
  8007aa:	51                   	push   %ecx
  8007ab:	50                   	push   %eax
  8007ac:	68 74 22 80 00       	push   $0x802274
  8007b1:	e8 b7 0c 00 00       	call   80146d <cprintf>
	*dev = 0;
  8007b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	56                   	push   %esi
  8007cd:	53                   	push   %ebx
  8007ce:	83 ec 10             	sub    $0x10,%esp
  8007d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007da:	50                   	push   %eax
  8007db:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8007e1:	c1 e8 0c             	shr    $0xc,%eax
  8007e4:	50                   	push   %eax
  8007e5:	e8 36 ff ff ff       	call   800720 <fd_lookup>
  8007ea:	83 c4 08             	add    $0x8,%esp
  8007ed:	85 c0                	test   %eax,%eax
  8007ef:	78 05                	js     8007f6 <fd_close+0x2d>
	    || fd != fd2)
  8007f1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8007f4:	74 0c                	je     800802 <fd_close+0x39>
		return (must_exist ? r : 0);
  8007f6:	84 db                	test   %bl,%bl
  8007f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fd:	0f 44 c2             	cmove  %edx,%eax
  800800:	eb 41                	jmp    800843 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800802:	83 ec 08             	sub    $0x8,%esp
  800805:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800808:	50                   	push   %eax
  800809:	ff 36                	pushl  (%esi)
  80080b:	e8 66 ff ff ff       	call   800776 <dev_lookup>
  800810:	89 c3                	mov    %eax,%ebx
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	85 c0                	test   %eax,%eax
  800817:	78 1a                	js     800833 <fd_close+0x6a>
		if (dev->dev_close)
  800819:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80081f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800824:	85 c0                	test   %eax,%eax
  800826:	74 0b                	je     800833 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800828:	83 ec 0c             	sub    $0xc,%esp
  80082b:	56                   	push   %esi
  80082c:	ff d0                	call   *%eax
  80082e:	89 c3                	mov    %eax,%ebx
  800830:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800833:	83 ec 08             	sub    $0x8,%esp
  800836:	56                   	push   %esi
  800837:	6a 00                	push   $0x0
  800839:	e8 ce f9 ff ff       	call   80020c <sys_page_unmap>
	return r;
  80083e:	83 c4 10             	add    $0x10,%esp
  800841:	89 d8                	mov    %ebx,%eax
}
  800843:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800850:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800853:	50                   	push   %eax
  800854:	ff 75 08             	pushl  0x8(%ebp)
  800857:	e8 c4 fe ff ff       	call   800720 <fd_lookup>
  80085c:	83 c4 08             	add    $0x8,%esp
  80085f:	85 c0                	test   %eax,%eax
  800861:	78 10                	js     800873 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800863:	83 ec 08             	sub    $0x8,%esp
  800866:	6a 01                	push   $0x1
  800868:	ff 75 f4             	pushl  -0xc(%ebp)
  80086b:	e8 59 ff ff ff       	call   8007c9 <fd_close>
  800870:	83 c4 10             	add    $0x10,%esp
}
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <close_all>:

void
close_all(void)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	53                   	push   %ebx
  800879:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80087c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800881:	83 ec 0c             	sub    $0xc,%esp
  800884:	53                   	push   %ebx
  800885:	e8 c0 ff ff ff       	call   80084a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80088a:	83 c3 01             	add    $0x1,%ebx
  80088d:	83 c4 10             	add    $0x10,%esp
  800890:	83 fb 20             	cmp    $0x20,%ebx
  800893:	75 ec                	jne    800881 <close_all+0xc>
		close(i);
}
  800895:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800898:	c9                   	leave  
  800899:	c3                   	ret    

0080089a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	57                   	push   %edi
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	83 ec 2c             	sub    $0x2c,%esp
  8008a3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008a9:	50                   	push   %eax
  8008aa:	ff 75 08             	pushl  0x8(%ebp)
  8008ad:	e8 6e fe ff ff       	call   800720 <fd_lookup>
  8008b2:	83 c4 08             	add    $0x8,%esp
  8008b5:	85 c0                	test   %eax,%eax
  8008b7:	0f 88 c1 00 00 00    	js     80097e <dup+0xe4>
		return r;
	close(newfdnum);
  8008bd:	83 ec 0c             	sub    $0xc,%esp
  8008c0:	56                   	push   %esi
  8008c1:	e8 84 ff ff ff       	call   80084a <close>

	newfd = INDEX2FD(newfdnum);
  8008c6:	89 f3                	mov    %esi,%ebx
  8008c8:	c1 e3 0c             	shl    $0xc,%ebx
  8008cb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008d1:	83 c4 04             	add    $0x4,%esp
  8008d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008d7:	e8 de fd ff ff       	call   8006ba <fd2data>
  8008dc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008de:	89 1c 24             	mov    %ebx,(%esp)
  8008e1:	e8 d4 fd ff ff       	call   8006ba <fd2data>
  8008e6:	83 c4 10             	add    $0x10,%esp
  8008e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8008ec:	89 f8                	mov    %edi,%eax
  8008ee:	c1 e8 16             	shr    $0x16,%eax
  8008f1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8008f8:	a8 01                	test   $0x1,%al
  8008fa:	74 37                	je     800933 <dup+0x99>
  8008fc:	89 f8                	mov    %edi,%eax
  8008fe:	c1 e8 0c             	shr    $0xc,%eax
  800901:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800908:	f6 c2 01             	test   $0x1,%dl
  80090b:	74 26                	je     800933 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80090d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800914:	83 ec 0c             	sub    $0xc,%esp
  800917:	25 07 0e 00 00       	and    $0xe07,%eax
  80091c:	50                   	push   %eax
  80091d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800920:	6a 00                	push   $0x0
  800922:	57                   	push   %edi
  800923:	6a 00                	push   $0x0
  800925:	e8 a0 f8 ff ff       	call   8001ca <sys_page_map>
  80092a:	89 c7                	mov    %eax,%edi
  80092c:	83 c4 20             	add    $0x20,%esp
  80092f:	85 c0                	test   %eax,%eax
  800931:	78 2e                	js     800961 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800933:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800936:	89 d0                	mov    %edx,%eax
  800938:	c1 e8 0c             	shr    $0xc,%eax
  80093b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800942:	83 ec 0c             	sub    $0xc,%esp
  800945:	25 07 0e 00 00       	and    $0xe07,%eax
  80094a:	50                   	push   %eax
  80094b:	53                   	push   %ebx
  80094c:	6a 00                	push   $0x0
  80094e:	52                   	push   %edx
  80094f:	6a 00                	push   $0x0
  800951:	e8 74 f8 ff ff       	call   8001ca <sys_page_map>
  800956:	89 c7                	mov    %eax,%edi
  800958:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80095b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80095d:	85 ff                	test   %edi,%edi
  80095f:	79 1d                	jns    80097e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800961:	83 ec 08             	sub    $0x8,%esp
  800964:	53                   	push   %ebx
  800965:	6a 00                	push   $0x0
  800967:	e8 a0 f8 ff ff       	call   80020c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80096c:	83 c4 08             	add    $0x8,%esp
  80096f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800972:	6a 00                	push   $0x0
  800974:	e8 93 f8 ff ff       	call   80020c <sys_page_unmap>
	return r;
  800979:	83 c4 10             	add    $0x10,%esp
  80097c:	89 f8                	mov    %edi,%eax
}
  80097e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800981:	5b                   	pop    %ebx
  800982:	5e                   	pop    %esi
  800983:	5f                   	pop    %edi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	53                   	push   %ebx
  80098a:	83 ec 14             	sub    $0x14,%esp
  80098d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800990:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800993:	50                   	push   %eax
  800994:	53                   	push   %ebx
  800995:	e8 86 fd ff ff       	call   800720 <fd_lookup>
  80099a:	83 c4 08             	add    $0x8,%esp
  80099d:	89 c2                	mov    %eax,%edx
  80099f:	85 c0                	test   %eax,%eax
  8009a1:	78 6d                	js     800a10 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009a3:	83 ec 08             	sub    $0x8,%esp
  8009a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009a9:	50                   	push   %eax
  8009aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ad:	ff 30                	pushl  (%eax)
  8009af:	e8 c2 fd ff ff       	call   800776 <dev_lookup>
  8009b4:	83 c4 10             	add    $0x10,%esp
  8009b7:	85 c0                	test   %eax,%eax
  8009b9:	78 4c                	js     800a07 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009be:	8b 42 08             	mov    0x8(%edx),%eax
  8009c1:	83 e0 03             	and    $0x3,%eax
  8009c4:	83 f8 01             	cmp    $0x1,%eax
  8009c7:	75 21                	jne    8009ea <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8009ce:	8b 40 54             	mov    0x54(%eax),%eax
  8009d1:	83 ec 04             	sub    $0x4,%esp
  8009d4:	53                   	push   %ebx
  8009d5:	50                   	push   %eax
  8009d6:	68 b5 22 80 00       	push   $0x8022b5
  8009db:	e8 8d 0a 00 00       	call   80146d <cprintf>
		return -E_INVAL;
  8009e0:	83 c4 10             	add    $0x10,%esp
  8009e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8009e8:	eb 26                	jmp    800a10 <read+0x8a>
	}
	if (!dev->dev_read)
  8009ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ed:	8b 40 08             	mov    0x8(%eax),%eax
  8009f0:	85 c0                	test   %eax,%eax
  8009f2:	74 17                	je     800a0b <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8009f4:	83 ec 04             	sub    $0x4,%esp
  8009f7:	ff 75 10             	pushl  0x10(%ebp)
  8009fa:	ff 75 0c             	pushl  0xc(%ebp)
  8009fd:	52                   	push   %edx
  8009fe:	ff d0                	call   *%eax
  800a00:	89 c2                	mov    %eax,%edx
  800a02:	83 c4 10             	add    $0x10,%esp
  800a05:	eb 09                	jmp    800a10 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a07:	89 c2                	mov    %eax,%edx
  800a09:	eb 05                	jmp    800a10 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a0b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a10:	89 d0                	mov    %edx,%eax
  800a12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	83 ec 0c             	sub    $0xc,%esp
  800a20:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a23:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a2b:	eb 21                	jmp    800a4e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a2d:	83 ec 04             	sub    $0x4,%esp
  800a30:	89 f0                	mov    %esi,%eax
  800a32:	29 d8                	sub    %ebx,%eax
  800a34:	50                   	push   %eax
  800a35:	89 d8                	mov    %ebx,%eax
  800a37:	03 45 0c             	add    0xc(%ebp),%eax
  800a3a:	50                   	push   %eax
  800a3b:	57                   	push   %edi
  800a3c:	e8 45 ff ff ff       	call   800986 <read>
		if (m < 0)
  800a41:	83 c4 10             	add    $0x10,%esp
  800a44:	85 c0                	test   %eax,%eax
  800a46:	78 10                	js     800a58 <readn+0x41>
			return m;
		if (m == 0)
  800a48:	85 c0                	test   %eax,%eax
  800a4a:	74 0a                	je     800a56 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a4c:	01 c3                	add    %eax,%ebx
  800a4e:	39 f3                	cmp    %esi,%ebx
  800a50:	72 db                	jb     800a2d <readn+0x16>
  800a52:	89 d8                	mov    %ebx,%eax
  800a54:	eb 02                	jmp    800a58 <readn+0x41>
  800a56:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5f                   	pop    %edi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	53                   	push   %ebx
  800a64:	83 ec 14             	sub    $0x14,%esp
  800a67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a6a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a6d:	50                   	push   %eax
  800a6e:	53                   	push   %ebx
  800a6f:	e8 ac fc ff ff       	call   800720 <fd_lookup>
  800a74:	83 c4 08             	add    $0x8,%esp
  800a77:	89 c2                	mov    %eax,%edx
  800a79:	85 c0                	test   %eax,%eax
  800a7b:	78 68                	js     800ae5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a7d:	83 ec 08             	sub    $0x8,%esp
  800a80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a83:	50                   	push   %eax
  800a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a87:	ff 30                	pushl  (%eax)
  800a89:	e8 e8 fc ff ff       	call   800776 <dev_lookup>
  800a8e:	83 c4 10             	add    $0x10,%esp
  800a91:	85 c0                	test   %eax,%eax
  800a93:	78 47                	js     800adc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a98:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a9c:	75 21                	jne    800abf <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800a9e:	a1 04 40 80 00       	mov    0x804004,%eax
  800aa3:	8b 40 54             	mov    0x54(%eax),%eax
  800aa6:	83 ec 04             	sub    $0x4,%esp
  800aa9:	53                   	push   %ebx
  800aaa:	50                   	push   %eax
  800aab:	68 d1 22 80 00       	push   $0x8022d1
  800ab0:	e8 b8 09 00 00       	call   80146d <cprintf>
		return -E_INVAL;
  800ab5:	83 c4 10             	add    $0x10,%esp
  800ab8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800abd:	eb 26                	jmp    800ae5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800abf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac2:	8b 52 0c             	mov    0xc(%edx),%edx
  800ac5:	85 d2                	test   %edx,%edx
  800ac7:	74 17                	je     800ae0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ac9:	83 ec 04             	sub    $0x4,%esp
  800acc:	ff 75 10             	pushl  0x10(%ebp)
  800acf:	ff 75 0c             	pushl  0xc(%ebp)
  800ad2:	50                   	push   %eax
  800ad3:	ff d2                	call   *%edx
  800ad5:	89 c2                	mov    %eax,%edx
  800ad7:	83 c4 10             	add    $0x10,%esp
  800ada:	eb 09                	jmp    800ae5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800adc:	89 c2                	mov    %eax,%edx
  800ade:	eb 05                	jmp    800ae5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ae0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800ae5:	89 d0                	mov    %edx,%eax
  800ae7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aea:	c9                   	leave  
  800aeb:	c3                   	ret    

00800aec <seek>:

int
seek(int fdnum, off_t offset)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800af2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800af5:	50                   	push   %eax
  800af6:	ff 75 08             	pushl  0x8(%ebp)
  800af9:	e8 22 fc ff ff       	call   800720 <fd_lookup>
  800afe:	83 c4 08             	add    $0x8,%esp
  800b01:	85 c0                	test   %eax,%eax
  800b03:	78 0e                	js     800b13 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b05:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b13:	c9                   	leave  
  800b14:	c3                   	ret    

00800b15 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	53                   	push   %ebx
  800b19:	83 ec 14             	sub    $0x14,%esp
  800b1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b22:	50                   	push   %eax
  800b23:	53                   	push   %ebx
  800b24:	e8 f7 fb ff ff       	call   800720 <fd_lookup>
  800b29:	83 c4 08             	add    $0x8,%esp
  800b2c:	89 c2                	mov    %eax,%edx
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	78 65                	js     800b97 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b32:	83 ec 08             	sub    $0x8,%esp
  800b35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b38:	50                   	push   %eax
  800b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b3c:	ff 30                	pushl  (%eax)
  800b3e:	e8 33 fc ff ff       	call   800776 <dev_lookup>
  800b43:	83 c4 10             	add    $0x10,%esp
  800b46:	85 c0                	test   %eax,%eax
  800b48:	78 44                	js     800b8e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b4d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b51:	75 21                	jne    800b74 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b53:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b58:	8b 40 54             	mov    0x54(%eax),%eax
  800b5b:	83 ec 04             	sub    $0x4,%esp
  800b5e:	53                   	push   %ebx
  800b5f:	50                   	push   %eax
  800b60:	68 94 22 80 00       	push   $0x802294
  800b65:	e8 03 09 00 00       	call   80146d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b6a:	83 c4 10             	add    $0x10,%esp
  800b6d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b72:	eb 23                	jmp    800b97 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b77:	8b 52 18             	mov    0x18(%edx),%edx
  800b7a:	85 d2                	test   %edx,%edx
  800b7c:	74 14                	je     800b92 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b7e:	83 ec 08             	sub    $0x8,%esp
  800b81:	ff 75 0c             	pushl  0xc(%ebp)
  800b84:	50                   	push   %eax
  800b85:	ff d2                	call   *%edx
  800b87:	89 c2                	mov    %eax,%edx
  800b89:	83 c4 10             	add    $0x10,%esp
  800b8c:	eb 09                	jmp    800b97 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b8e:	89 c2                	mov    %eax,%edx
  800b90:	eb 05                	jmp    800b97 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800b92:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800b97:	89 d0                	mov    %edx,%eax
  800b99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	53                   	push   %ebx
  800ba2:	83 ec 14             	sub    $0x14,%esp
  800ba5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ba8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bab:	50                   	push   %eax
  800bac:	ff 75 08             	pushl  0x8(%ebp)
  800baf:	e8 6c fb ff ff       	call   800720 <fd_lookup>
  800bb4:	83 c4 08             	add    $0x8,%esp
  800bb7:	89 c2                	mov    %eax,%edx
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	78 58                	js     800c15 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bbd:	83 ec 08             	sub    $0x8,%esp
  800bc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bc3:	50                   	push   %eax
  800bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc7:	ff 30                	pushl  (%eax)
  800bc9:	e8 a8 fb ff ff       	call   800776 <dev_lookup>
  800bce:	83 c4 10             	add    $0x10,%esp
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	78 37                	js     800c0c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bd8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800bdc:	74 32                	je     800c10 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800bde:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800be1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800be8:	00 00 00 
	stat->st_isdir = 0;
  800beb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bf2:	00 00 00 
	stat->st_dev = dev;
  800bf5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800bfb:	83 ec 08             	sub    $0x8,%esp
  800bfe:	53                   	push   %ebx
  800bff:	ff 75 f0             	pushl  -0x10(%ebp)
  800c02:	ff 50 14             	call   *0x14(%eax)
  800c05:	89 c2                	mov    %eax,%edx
  800c07:	83 c4 10             	add    $0x10,%esp
  800c0a:	eb 09                	jmp    800c15 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c0c:	89 c2                	mov    %eax,%edx
  800c0e:	eb 05                	jmp    800c15 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c10:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c15:	89 d0                	mov    %edx,%eax
  800c17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1a:	c9                   	leave  
  800c1b:	c3                   	ret    

00800c1c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c21:	83 ec 08             	sub    $0x8,%esp
  800c24:	6a 00                	push   $0x0
  800c26:	ff 75 08             	pushl  0x8(%ebp)
  800c29:	e8 e3 01 00 00       	call   800e11 <open>
  800c2e:	89 c3                	mov    %eax,%ebx
  800c30:	83 c4 10             	add    $0x10,%esp
  800c33:	85 c0                	test   %eax,%eax
  800c35:	78 1b                	js     800c52 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c37:	83 ec 08             	sub    $0x8,%esp
  800c3a:	ff 75 0c             	pushl  0xc(%ebp)
  800c3d:	50                   	push   %eax
  800c3e:	e8 5b ff ff ff       	call   800b9e <fstat>
  800c43:	89 c6                	mov    %eax,%esi
	close(fd);
  800c45:	89 1c 24             	mov    %ebx,(%esp)
  800c48:	e8 fd fb ff ff       	call   80084a <close>
	return r;
  800c4d:	83 c4 10             	add    $0x10,%esp
  800c50:	89 f0                	mov    %esi,%eax
}
  800c52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	89 c6                	mov    %eax,%esi
  800c60:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c62:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c69:	75 12                	jne    800c7d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	6a 01                	push   $0x1
  800c70:	e8 2d 12 00 00       	call   801ea2 <ipc_find_env>
  800c75:	a3 00 40 80 00       	mov    %eax,0x804000
  800c7a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c7d:	6a 07                	push   $0x7
  800c7f:	68 00 50 80 00       	push   $0x805000
  800c84:	56                   	push   %esi
  800c85:	ff 35 00 40 80 00    	pushl  0x804000
  800c8b:	e8 b0 11 00 00       	call   801e40 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c90:	83 c4 0c             	add    $0xc,%esp
  800c93:	6a 00                	push   $0x0
  800c95:	53                   	push   %ebx
  800c96:	6a 00                	push   $0x0
  800c98:	e8 2b 11 00 00       	call   801dc8 <ipc_recv>
}
  800c9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800caa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cad:	8b 40 0c             	mov    0xc(%eax),%eax
  800cb0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc2:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc7:	e8 8d ff ff ff       	call   800c59 <fsipc>
}
  800ccc:	c9                   	leave  
  800ccd:	c3                   	ret    

00800cce <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd7:	8b 40 0c             	mov    0xc(%eax),%eax
  800cda:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800cdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce4:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce9:	e8 6b ff ff ff       	call   800c59 <fsipc>
}
  800cee:	c9                   	leave  
  800cef:	c3                   	ret    

00800cf0 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 04             	sub    $0x4,%esp
  800cf7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfd:	8b 40 0c             	mov    0xc(%eax),%eax
  800d00:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d05:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d0f:	e8 45 ff ff ff       	call   800c59 <fsipc>
  800d14:	85 c0                	test   %eax,%eax
  800d16:	78 2c                	js     800d44 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d18:	83 ec 08             	sub    $0x8,%esp
  800d1b:	68 00 50 80 00       	push   $0x805000
  800d20:	53                   	push   %ebx
  800d21:	e8 cc 0c 00 00       	call   8019f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d26:	a1 80 50 80 00       	mov    0x805080,%eax
  800d2b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d31:	a1 84 50 80 00       	mov    0x805084,%eax
  800d36:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d3c:	83 c4 10             	add    $0x10,%esp
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d47:	c9                   	leave  
  800d48:	c3                   	ret    

00800d49 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	8b 52 0c             	mov    0xc(%edx),%edx
  800d58:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d5e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d63:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d68:	0f 47 c2             	cmova  %edx,%eax
  800d6b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d70:	50                   	push   %eax
  800d71:	ff 75 0c             	pushl  0xc(%ebp)
  800d74:	68 08 50 80 00       	push   $0x805008
  800d79:	e8 06 0e 00 00       	call   801b84 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d83:	b8 04 00 00 00       	mov    $0x4,%eax
  800d88:	e8 cc fe ff ff       	call   800c59 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800d8d:	c9                   	leave  
  800d8e:	c3                   	ret    

00800d8f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9a:	8b 40 0c             	mov    0xc(%eax),%eax
  800d9d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800da2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800da8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dad:	b8 03 00 00 00       	mov    $0x3,%eax
  800db2:	e8 a2 fe ff ff       	call   800c59 <fsipc>
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	78 4b                	js     800e08 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800dbd:	39 c6                	cmp    %eax,%esi
  800dbf:	73 16                	jae    800dd7 <devfile_read+0x48>
  800dc1:	68 00 23 80 00       	push   $0x802300
  800dc6:	68 07 23 80 00       	push   $0x802307
  800dcb:	6a 7c                	push   $0x7c
  800dcd:	68 1c 23 80 00       	push   $0x80231c
  800dd2:	e8 bd 05 00 00       	call   801394 <_panic>
	assert(r <= PGSIZE);
  800dd7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ddc:	7e 16                	jle    800df4 <devfile_read+0x65>
  800dde:	68 27 23 80 00       	push   $0x802327
  800de3:	68 07 23 80 00       	push   $0x802307
  800de8:	6a 7d                	push   $0x7d
  800dea:	68 1c 23 80 00       	push   $0x80231c
  800def:	e8 a0 05 00 00       	call   801394 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800df4:	83 ec 04             	sub    $0x4,%esp
  800df7:	50                   	push   %eax
  800df8:	68 00 50 80 00       	push   $0x805000
  800dfd:	ff 75 0c             	pushl  0xc(%ebp)
  800e00:	e8 7f 0d 00 00       	call   801b84 <memmove>
	return r;
  800e05:	83 c4 10             	add    $0x10,%esp
}
  800e08:	89 d8                	mov    %ebx,%eax
  800e0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	53                   	push   %ebx
  800e15:	83 ec 20             	sub    $0x20,%esp
  800e18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e1b:	53                   	push   %ebx
  800e1c:	e8 98 0b 00 00       	call   8019b9 <strlen>
  800e21:	83 c4 10             	add    $0x10,%esp
  800e24:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e29:	7f 67                	jg     800e92 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e2b:	83 ec 0c             	sub    $0xc,%esp
  800e2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e31:	50                   	push   %eax
  800e32:	e8 9a f8 ff ff       	call   8006d1 <fd_alloc>
  800e37:	83 c4 10             	add    $0x10,%esp
		return r;
  800e3a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	78 57                	js     800e97 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e40:	83 ec 08             	sub    $0x8,%esp
  800e43:	53                   	push   %ebx
  800e44:	68 00 50 80 00       	push   $0x805000
  800e49:	e8 a4 0b 00 00       	call   8019f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e51:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e59:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5e:	e8 f6 fd ff ff       	call   800c59 <fsipc>
  800e63:	89 c3                	mov    %eax,%ebx
  800e65:	83 c4 10             	add    $0x10,%esp
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	79 14                	jns    800e80 <open+0x6f>
		fd_close(fd, 0);
  800e6c:	83 ec 08             	sub    $0x8,%esp
  800e6f:	6a 00                	push   $0x0
  800e71:	ff 75 f4             	pushl  -0xc(%ebp)
  800e74:	e8 50 f9 ff ff       	call   8007c9 <fd_close>
		return r;
  800e79:	83 c4 10             	add    $0x10,%esp
  800e7c:	89 da                	mov    %ebx,%edx
  800e7e:	eb 17                	jmp    800e97 <open+0x86>
	}

	return fd2num(fd);
  800e80:	83 ec 0c             	sub    $0xc,%esp
  800e83:	ff 75 f4             	pushl  -0xc(%ebp)
  800e86:	e8 1f f8 ff ff       	call   8006aa <fd2num>
  800e8b:	89 c2                	mov    %eax,%edx
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	eb 05                	jmp    800e97 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800e92:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800e97:	89 d0                	mov    %edx,%eax
  800e99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e9c:	c9                   	leave  
  800e9d:	c3                   	ret    

00800e9e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ea4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea9:	b8 08 00 00 00       	mov    $0x8,%eax
  800eae:	e8 a6 fd ff ff       	call   800c59 <fsipc>
}
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
  800eba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ebd:	83 ec 0c             	sub    $0xc,%esp
  800ec0:	ff 75 08             	pushl  0x8(%ebp)
  800ec3:	e8 f2 f7 ff ff       	call   8006ba <fd2data>
  800ec8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800eca:	83 c4 08             	add    $0x8,%esp
  800ecd:	68 33 23 80 00       	push   $0x802333
  800ed2:	53                   	push   %ebx
  800ed3:	e8 1a 0b 00 00       	call   8019f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ed8:	8b 46 04             	mov    0x4(%esi),%eax
  800edb:	2b 06                	sub    (%esi),%eax
  800edd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ee3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800eea:	00 00 00 
	stat->st_dev = &devpipe;
  800eed:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ef4:	30 80 00 
	return 0;
}
  800ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  800efc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eff:	5b                   	pop    %ebx
  800f00:	5e                   	pop    %esi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	53                   	push   %ebx
  800f07:	83 ec 0c             	sub    $0xc,%esp
  800f0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f0d:	53                   	push   %ebx
  800f0e:	6a 00                	push   $0x0
  800f10:	e8 f7 f2 ff ff       	call   80020c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f15:	89 1c 24             	mov    %ebx,(%esp)
  800f18:	e8 9d f7 ff ff       	call   8006ba <fd2data>
  800f1d:	83 c4 08             	add    $0x8,%esp
  800f20:	50                   	push   %eax
  800f21:	6a 00                	push   $0x0
  800f23:	e8 e4 f2 ff ff       	call   80020c <sys_page_unmap>
}
  800f28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    

00800f2d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	57                   	push   %edi
  800f31:	56                   	push   %esi
  800f32:	53                   	push   %ebx
  800f33:	83 ec 1c             	sub    $0x1c,%esp
  800f36:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f39:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f3b:	a1 04 40 80 00       	mov    0x804004,%eax
  800f40:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f43:	83 ec 0c             	sub    $0xc,%esp
  800f46:	ff 75 e0             	pushl  -0x20(%ebp)
  800f49:	e8 94 0f 00 00       	call   801ee2 <pageref>
  800f4e:	89 c3                	mov    %eax,%ebx
  800f50:	89 3c 24             	mov    %edi,(%esp)
  800f53:	e8 8a 0f 00 00       	call   801ee2 <pageref>
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	39 c3                	cmp    %eax,%ebx
  800f5d:	0f 94 c1             	sete   %cl
  800f60:	0f b6 c9             	movzbl %cl,%ecx
  800f63:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f66:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f6c:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  800f6f:	39 ce                	cmp    %ecx,%esi
  800f71:	74 1b                	je     800f8e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800f73:	39 c3                	cmp    %eax,%ebx
  800f75:	75 c4                	jne    800f3b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f77:	8b 42 64             	mov    0x64(%edx),%eax
  800f7a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f7d:	50                   	push   %eax
  800f7e:	56                   	push   %esi
  800f7f:	68 3a 23 80 00       	push   $0x80233a
  800f84:	e8 e4 04 00 00       	call   80146d <cprintf>
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	eb ad                	jmp    800f3b <_pipeisclosed+0xe>
	}
}
  800f8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f94:	5b                   	pop    %ebx
  800f95:	5e                   	pop    %esi
  800f96:	5f                   	pop    %edi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	57                   	push   %edi
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	83 ec 28             	sub    $0x28,%esp
  800fa2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800fa5:	56                   	push   %esi
  800fa6:	e8 0f f7 ff ff       	call   8006ba <fd2data>
  800fab:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb5:	eb 4b                	jmp    801002 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fb7:	89 da                	mov    %ebx,%edx
  800fb9:	89 f0                	mov    %esi,%eax
  800fbb:	e8 6d ff ff ff       	call   800f2d <_pipeisclosed>
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	75 48                	jne    80100c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fc4:	e8 9f f1 ff ff       	call   800168 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fc9:	8b 43 04             	mov    0x4(%ebx),%eax
  800fcc:	8b 0b                	mov    (%ebx),%ecx
  800fce:	8d 51 20             	lea    0x20(%ecx),%edx
  800fd1:	39 d0                	cmp    %edx,%eax
  800fd3:	73 e2                	jae    800fb7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800fd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800fdc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800fdf:	89 c2                	mov    %eax,%edx
  800fe1:	c1 fa 1f             	sar    $0x1f,%edx
  800fe4:	89 d1                	mov    %edx,%ecx
  800fe6:	c1 e9 1b             	shr    $0x1b,%ecx
  800fe9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800fec:	83 e2 1f             	and    $0x1f,%edx
  800fef:	29 ca                	sub    %ecx,%edx
  800ff1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ff5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ff9:	83 c0 01             	add    $0x1,%eax
  800ffc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fff:	83 c7 01             	add    $0x1,%edi
  801002:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801005:	75 c2                	jne    800fc9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801007:	8b 45 10             	mov    0x10(%ebp),%eax
  80100a:	eb 05                	jmp    801011 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80100c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801011:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801014:	5b                   	pop    %ebx
  801015:	5e                   	pop    %esi
  801016:	5f                   	pop    %edi
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	57                   	push   %edi
  80101d:	56                   	push   %esi
  80101e:	53                   	push   %ebx
  80101f:	83 ec 18             	sub    $0x18,%esp
  801022:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801025:	57                   	push   %edi
  801026:	e8 8f f6 ff ff       	call   8006ba <fd2data>
  80102b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	bb 00 00 00 00       	mov    $0x0,%ebx
  801035:	eb 3d                	jmp    801074 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801037:	85 db                	test   %ebx,%ebx
  801039:	74 04                	je     80103f <devpipe_read+0x26>
				return i;
  80103b:	89 d8                	mov    %ebx,%eax
  80103d:	eb 44                	jmp    801083 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80103f:	89 f2                	mov    %esi,%edx
  801041:	89 f8                	mov    %edi,%eax
  801043:	e8 e5 fe ff ff       	call   800f2d <_pipeisclosed>
  801048:	85 c0                	test   %eax,%eax
  80104a:	75 32                	jne    80107e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80104c:	e8 17 f1 ff ff       	call   800168 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801051:	8b 06                	mov    (%esi),%eax
  801053:	3b 46 04             	cmp    0x4(%esi),%eax
  801056:	74 df                	je     801037 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801058:	99                   	cltd   
  801059:	c1 ea 1b             	shr    $0x1b,%edx
  80105c:	01 d0                	add    %edx,%eax
  80105e:	83 e0 1f             	and    $0x1f,%eax
  801061:	29 d0                	sub    %edx,%eax
  801063:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801068:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80106e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801071:	83 c3 01             	add    $0x1,%ebx
  801074:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801077:	75 d8                	jne    801051 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801079:	8b 45 10             	mov    0x10(%ebp),%eax
  80107c:	eb 05                	jmp    801083 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80107e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801083:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801086:	5b                   	pop    %ebx
  801087:	5e                   	pop    %esi
  801088:	5f                   	pop    %edi
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    

0080108b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	56                   	push   %esi
  80108f:	53                   	push   %ebx
  801090:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801093:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801096:	50                   	push   %eax
  801097:	e8 35 f6 ff ff       	call   8006d1 <fd_alloc>
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	89 c2                	mov    %eax,%edx
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	0f 88 2c 01 00 00    	js     8011d5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010a9:	83 ec 04             	sub    $0x4,%esp
  8010ac:	68 07 04 00 00       	push   $0x407
  8010b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b4:	6a 00                	push   $0x0
  8010b6:	e8 cc f0 ff ff       	call   800187 <sys_page_alloc>
  8010bb:	83 c4 10             	add    $0x10,%esp
  8010be:	89 c2                	mov    %eax,%edx
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	0f 88 0d 01 00 00    	js     8011d5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ce:	50                   	push   %eax
  8010cf:	e8 fd f5 ff ff       	call   8006d1 <fd_alloc>
  8010d4:	89 c3                	mov    %eax,%ebx
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	0f 88 e2 00 00 00    	js     8011c3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010e1:	83 ec 04             	sub    $0x4,%esp
  8010e4:	68 07 04 00 00       	push   $0x407
  8010e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8010ec:	6a 00                	push   $0x0
  8010ee:	e8 94 f0 ff ff       	call   800187 <sys_page_alloc>
  8010f3:	89 c3                	mov    %eax,%ebx
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	0f 88 c3 00 00 00    	js     8011c3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801100:	83 ec 0c             	sub    $0xc,%esp
  801103:	ff 75 f4             	pushl  -0xc(%ebp)
  801106:	e8 af f5 ff ff       	call   8006ba <fd2data>
  80110b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80110d:	83 c4 0c             	add    $0xc,%esp
  801110:	68 07 04 00 00       	push   $0x407
  801115:	50                   	push   %eax
  801116:	6a 00                	push   $0x0
  801118:	e8 6a f0 ff ff       	call   800187 <sys_page_alloc>
  80111d:	89 c3                	mov    %eax,%ebx
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	85 c0                	test   %eax,%eax
  801124:	0f 88 89 00 00 00    	js     8011b3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80112a:	83 ec 0c             	sub    $0xc,%esp
  80112d:	ff 75 f0             	pushl  -0x10(%ebp)
  801130:	e8 85 f5 ff ff       	call   8006ba <fd2data>
  801135:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80113c:	50                   	push   %eax
  80113d:	6a 00                	push   $0x0
  80113f:	56                   	push   %esi
  801140:	6a 00                	push   $0x0
  801142:	e8 83 f0 ff ff       	call   8001ca <sys_page_map>
  801147:	89 c3                	mov    %eax,%ebx
  801149:	83 c4 20             	add    $0x20,%esp
  80114c:	85 c0                	test   %eax,%eax
  80114e:	78 55                	js     8011a5 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801150:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801156:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801159:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80115b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801165:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80116b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801170:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801173:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80117a:	83 ec 0c             	sub    $0xc,%esp
  80117d:	ff 75 f4             	pushl  -0xc(%ebp)
  801180:	e8 25 f5 ff ff       	call   8006aa <fd2num>
  801185:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801188:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80118a:	83 c4 04             	add    $0x4,%esp
  80118d:	ff 75 f0             	pushl  -0x10(%ebp)
  801190:	e8 15 f5 ff ff       	call   8006aa <fd2num>
  801195:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801198:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a3:	eb 30                	jmp    8011d5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	56                   	push   %esi
  8011a9:	6a 00                	push   $0x0
  8011ab:	e8 5c f0 ff ff       	call   80020c <sys_page_unmap>
  8011b0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8011b9:	6a 00                	push   $0x0
  8011bb:	e8 4c f0 ff ff       	call   80020c <sys_page_unmap>
  8011c0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8011c9:	6a 00                	push   $0x0
  8011cb:	e8 3c f0 ff ff       	call   80020c <sys_page_unmap>
  8011d0:	83 c4 10             	add    $0x10,%esp
  8011d3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011d5:	89 d0                	mov    %edx,%eax
  8011d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011da:	5b                   	pop    %ebx
  8011db:	5e                   	pop    %esi
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e7:	50                   	push   %eax
  8011e8:	ff 75 08             	pushl  0x8(%ebp)
  8011eb:	e8 30 f5 ff ff       	call   800720 <fd_lookup>
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 18                	js     80120f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8011f7:	83 ec 0c             	sub    $0xc,%esp
  8011fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8011fd:	e8 b8 f4 ff ff       	call   8006ba <fd2data>
	return _pipeisclosed(fd, p);
  801202:	89 c2                	mov    %eax,%edx
  801204:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801207:	e8 21 fd ff ff       	call   800f2d <_pipeisclosed>
  80120c:	83 c4 10             	add    $0x10,%esp
}
  80120f:	c9                   	leave  
  801210:	c3                   	ret    

00801211 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801214:	b8 00 00 00 00       	mov    $0x0,%eax
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801221:	68 52 23 80 00       	push   $0x802352
  801226:	ff 75 0c             	pushl  0xc(%ebp)
  801229:	e8 c4 07 00 00       	call   8019f2 <strcpy>
	return 0;
}
  80122e:	b8 00 00 00 00       	mov    $0x0,%eax
  801233:	c9                   	leave  
  801234:	c3                   	ret    

00801235 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	57                   	push   %edi
  801239:	56                   	push   %esi
  80123a:	53                   	push   %ebx
  80123b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801241:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801246:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80124c:	eb 2d                	jmp    80127b <devcons_write+0x46>
		m = n - tot;
  80124e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801251:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801253:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801256:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80125b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	53                   	push   %ebx
  801262:	03 45 0c             	add    0xc(%ebp),%eax
  801265:	50                   	push   %eax
  801266:	57                   	push   %edi
  801267:	e8 18 09 00 00       	call   801b84 <memmove>
		sys_cputs(buf, m);
  80126c:	83 c4 08             	add    $0x8,%esp
  80126f:	53                   	push   %ebx
  801270:	57                   	push   %edi
  801271:	e8 55 ee ff ff       	call   8000cb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801276:	01 de                	add    %ebx,%esi
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	89 f0                	mov    %esi,%eax
  80127d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801280:	72 cc                	jb     80124e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801285:	5b                   	pop    %ebx
  801286:	5e                   	pop    %esi
  801287:	5f                   	pop    %edi
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801295:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801299:	74 2a                	je     8012c5 <devcons_read+0x3b>
  80129b:	eb 05                	jmp    8012a2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80129d:	e8 c6 ee ff ff       	call   800168 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012a2:	e8 42 ee ff ff       	call   8000e9 <sys_cgetc>
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	74 f2                	je     80129d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 16                	js     8012c5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012af:	83 f8 04             	cmp    $0x4,%eax
  8012b2:	74 0c                	je     8012c0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b7:	88 02                	mov    %al,(%edx)
	return 1;
  8012b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8012be:	eb 05                	jmp    8012c5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012c0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012c5:	c9                   	leave  
  8012c6:	c3                   	ret    

008012c7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012d3:	6a 01                	push   $0x1
  8012d5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	e8 ed ed ff ff       	call   8000cb <sys_cputs>
}
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	c9                   	leave  
  8012e2:	c3                   	ret    

008012e3 <getchar>:

int
getchar(void)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8012e9:	6a 01                	push   $0x1
  8012eb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012ee:	50                   	push   %eax
  8012ef:	6a 00                	push   $0x0
  8012f1:	e8 90 f6 ff ff       	call   800986 <read>
	if (r < 0)
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	78 0f                	js     80130c <getchar+0x29>
		return r;
	if (r < 1)
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	7e 06                	jle    801307 <getchar+0x24>
		return -E_EOF;
	return c;
  801301:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801305:	eb 05                	jmp    80130c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801307:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80130c:	c9                   	leave  
  80130d:	c3                   	ret    

0080130e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801314:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801317:	50                   	push   %eax
  801318:	ff 75 08             	pushl  0x8(%ebp)
  80131b:	e8 00 f4 ff ff       	call   800720 <fd_lookup>
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	85 c0                	test   %eax,%eax
  801325:	78 11                	js     801338 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801327:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801330:	39 10                	cmp    %edx,(%eax)
  801332:	0f 94 c0             	sete   %al
  801335:	0f b6 c0             	movzbl %al,%eax
}
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <opencons>:

int
opencons(void)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801340:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801343:	50                   	push   %eax
  801344:	e8 88 f3 ff ff       	call   8006d1 <fd_alloc>
  801349:	83 c4 10             	add    $0x10,%esp
		return r;
  80134c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 3e                	js     801390 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801352:	83 ec 04             	sub    $0x4,%esp
  801355:	68 07 04 00 00       	push   $0x407
  80135a:	ff 75 f4             	pushl  -0xc(%ebp)
  80135d:	6a 00                	push   $0x0
  80135f:	e8 23 ee ff ff       	call   800187 <sys_page_alloc>
  801364:	83 c4 10             	add    $0x10,%esp
		return r;
  801367:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801369:	85 c0                	test   %eax,%eax
  80136b:	78 23                	js     801390 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80136d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801373:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801376:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801378:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801382:	83 ec 0c             	sub    $0xc,%esp
  801385:	50                   	push   %eax
  801386:	e8 1f f3 ff ff       	call   8006aa <fd2num>
  80138b:	89 c2                	mov    %eax,%edx
  80138d:	83 c4 10             	add    $0x10,%esp
}
  801390:	89 d0                	mov    %edx,%eax
  801392:	c9                   	leave  
  801393:	c3                   	ret    

00801394 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	56                   	push   %esi
  801398:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801399:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80139c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013a2:	e8 a2 ed ff ff       	call   800149 <sys_getenvid>
  8013a7:	83 ec 0c             	sub    $0xc,%esp
  8013aa:	ff 75 0c             	pushl  0xc(%ebp)
  8013ad:	ff 75 08             	pushl  0x8(%ebp)
  8013b0:	56                   	push   %esi
  8013b1:	50                   	push   %eax
  8013b2:	68 60 23 80 00       	push   $0x802360
  8013b7:	e8 b1 00 00 00       	call   80146d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013bc:	83 c4 18             	add    $0x18,%esp
  8013bf:	53                   	push   %ebx
  8013c0:	ff 75 10             	pushl  0x10(%ebp)
  8013c3:	e8 54 00 00 00       	call   80141c <vcprintf>
	cprintf("\n");
  8013c8:	c7 04 24 4b 23 80 00 	movl   $0x80234b,(%esp)
  8013cf:	e8 99 00 00 00       	call   80146d <cprintf>
  8013d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013d7:	cc                   	int3   
  8013d8:	eb fd                	jmp    8013d7 <_panic+0x43>

008013da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	53                   	push   %ebx
  8013de:	83 ec 04             	sub    $0x4,%esp
  8013e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013e4:	8b 13                	mov    (%ebx),%edx
  8013e6:	8d 42 01             	lea    0x1(%edx),%eax
  8013e9:	89 03                	mov    %eax,(%ebx)
  8013eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013f7:	75 1a                	jne    801413 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	68 ff 00 00 00       	push   $0xff
  801401:	8d 43 08             	lea    0x8(%ebx),%eax
  801404:	50                   	push   %eax
  801405:	e8 c1 ec ff ff       	call   8000cb <sys_cputs>
		b->idx = 0;
  80140a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801410:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801413:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801417:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801425:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80142c:	00 00 00 
	b.cnt = 0;
  80142f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801436:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801439:	ff 75 0c             	pushl  0xc(%ebp)
  80143c:	ff 75 08             	pushl  0x8(%ebp)
  80143f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	68 da 13 80 00       	push   $0x8013da
  80144b:	e8 54 01 00 00       	call   8015a4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801450:	83 c4 08             	add    $0x8,%esp
  801453:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801459:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80145f:	50                   	push   %eax
  801460:	e8 66 ec ff ff       	call   8000cb <sys_cputs>

	return b.cnt;
}
  801465:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80146b:	c9                   	leave  
  80146c:	c3                   	ret    

0080146d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801473:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801476:	50                   	push   %eax
  801477:	ff 75 08             	pushl  0x8(%ebp)
  80147a:	e8 9d ff ff ff       	call   80141c <vcprintf>
	va_end(ap);

	return cnt;
}
  80147f:	c9                   	leave  
  801480:	c3                   	ret    

00801481 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	57                   	push   %edi
  801485:	56                   	push   %esi
  801486:	53                   	push   %ebx
  801487:	83 ec 1c             	sub    $0x1c,%esp
  80148a:	89 c7                	mov    %eax,%edi
  80148c:	89 d6                	mov    %edx,%esi
  80148e:	8b 45 08             	mov    0x8(%ebp),%eax
  801491:	8b 55 0c             	mov    0xc(%ebp),%edx
  801494:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801497:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80149a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80149d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014a5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014a8:	39 d3                	cmp    %edx,%ebx
  8014aa:	72 05                	jb     8014b1 <printnum+0x30>
  8014ac:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014af:	77 45                	ja     8014f6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014b1:	83 ec 0c             	sub    $0xc,%esp
  8014b4:	ff 75 18             	pushl  0x18(%ebp)
  8014b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ba:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014bd:	53                   	push   %ebx
  8014be:	ff 75 10             	pushl  0x10(%ebp)
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8014ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8014cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8014d0:	e8 4b 0a 00 00       	call   801f20 <__udivdi3>
  8014d5:	83 c4 18             	add    $0x18,%esp
  8014d8:	52                   	push   %edx
  8014d9:	50                   	push   %eax
  8014da:	89 f2                	mov    %esi,%edx
  8014dc:	89 f8                	mov    %edi,%eax
  8014de:	e8 9e ff ff ff       	call   801481 <printnum>
  8014e3:	83 c4 20             	add    $0x20,%esp
  8014e6:	eb 18                	jmp    801500 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	56                   	push   %esi
  8014ec:	ff 75 18             	pushl  0x18(%ebp)
  8014ef:	ff d7                	call   *%edi
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	eb 03                	jmp    8014f9 <printnum+0x78>
  8014f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014f9:	83 eb 01             	sub    $0x1,%ebx
  8014fc:	85 db                	test   %ebx,%ebx
  8014fe:	7f e8                	jg     8014e8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801500:	83 ec 08             	sub    $0x8,%esp
  801503:	56                   	push   %esi
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	ff 75 e4             	pushl  -0x1c(%ebp)
  80150a:	ff 75 e0             	pushl  -0x20(%ebp)
  80150d:	ff 75 dc             	pushl  -0x24(%ebp)
  801510:	ff 75 d8             	pushl  -0x28(%ebp)
  801513:	e8 38 0b 00 00       	call   802050 <__umoddi3>
  801518:	83 c4 14             	add    $0x14,%esp
  80151b:	0f be 80 83 23 80 00 	movsbl 0x802383(%eax),%eax
  801522:	50                   	push   %eax
  801523:	ff d7                	call   *%edi
}
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152b:	5b                   	pop    %ebx
  80152c:	5e                   	pop    %esi
  80152d:	5f                   	pop    %edi
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801533:	83 fa 01             	cmp    $0x1,%edx
  801536:	7e 0e                	jle    801546 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801538:	8b 10                	mov    (%eax),%edx
  80153a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80153d:	89 08                	mov    %ecx,(%eax)
  80153f:	8b 02                	mov    (%edx),%eax
  801541:	8b 52 04             	mov    0x4(%edx),%edx
  801544:	eb 22                	jmp    801568 <getuint+0x38>
	else if (lflag)
  801546:	85 d2                	test   %edx,%edx
  801548:	74 10                	je     80155a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80154a:	8b 10                	mov    (%eax),%edx
  80154c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80154f:	89 08                	mov    %ecx,(%eax)
  801551:	8b 02                	mov    (%edx),%eax
  801553:	ba 00 00 00 00       	mov    $0x0,%edx
  801558:	eb 0e                	jmp    801568 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80155a:	8b 10                	mov    (%eax),%edx
  80155c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80155f:	89 08                	mov    %ecx,(%eax)
  801561:	8b 02                	mov    (%edx),%eax
  801563:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    

0080156a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801570:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801574:	8b 10                	mov    (%eax),%edx
  801576:	3b 50 04             	cmp    0x4(%eax),%edx
  801579:	73 0a                	jae    801585 <sprintputch+0x1b>
		*b->buf++ = ch;
  80157b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80157e:	89 08                	mov    %ecx,(%eax)
  801580:	8b 45 08             	mov    0x8(%ebp),%eax
  801583:	88 02                	mov    %al,(%edx)
}
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    

00801587 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80158d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801590:	50                   	push   %eax
  801591:	ff 75 10             	pushl  0x10(%ebp)
  801594:	ff 75 0c             	pushl  0xc(%ebp)
  801597:	ff 75 08             	pushl  0x8(%ebp)
  80159a:	e8 05 00 00 00       	call   8015a4 <vprintfmt>
	va_end(ap);
}
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	c9                   	leave  
  8015a3:	c3                   	ret    

008015a4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	57                   	push   %edi
  8015a8:	56                   	push   %esi
  8015a9:	53                   	push   %ebx
  8015aa:	83 ec 2c             	sub    $0x2c,%esp
  8015ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015b3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015b6:	eb 12                	jmp    8015ca <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	0f 84 89 03 00 00    	je     801949 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015c0:	83 ec 08             	sub    $0x8,%esp
  8015c3:	53                   	push   %ebx
  8015c4:	50                   	push   %eax
  8015c5:	ff d6                	call   *%esi
  8015c7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015ca:	83 c7 01             	add    $0x1,%edi
  8015cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015d1:	83 f8 25             	cmp    $0x25,%eax
  8015d4:	75 e2                	jne    8015b8 <vprintfmt+0x14>
  8015d6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015da:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015e1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8015e8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8015ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f4:	eb 07                	jmp    8015fd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8015f9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015fd:	8d 47 01             	lea    0x1(%edi),%eax
  801600:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801603:	0f b6 07             	movzbl (%edi),%eax
  801606:	0f b6 c8             	movzbl %al,%ecx
  801609:	83 e8 23             	sub    $0x23,%eax
  80160c:	3c 55                	cmp    $0x55,%al
  80160e:	0f 87 1a 03 00 00    	ja     80192e <vprintfmt+0x38a>
  801614:	0f b6 c0             	movzbl %al,%eax
  801617:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  80161e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801621:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801625:	eb d6                	jmp    8015fd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801627:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80162a:	b8 00 00 00 00       	mov    $0x0,%eax
  80162f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801632:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801635:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801639:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80163c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80163f:	83 fa 09             	cmp    $0x9,%edx
  801642:	77 39                	ja     80167d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801644:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801647:	eb e9                	jmp    801632 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801649:	8b 45 14             	mov    0x14(%ebp),%eax
  80164c:	8d 48 04             	lea    0x4(%eax),%ecx
  80164f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801652:	8b 00                	mov    (%eax),%eax
  801654:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801657:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80165a:	eb 27                	jmp    801683 <vprintfmt+0xdf>
  80165c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80165f:	85 c0                	test   %eax,%eax
  801661:	b9 00 00 00 00       	mov    $0x0,%ecx
  801666:	0f 49 c8             	cmovns %eax,%ecx
  801669:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80166c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80166f:	eb 8c                	jmp    8015fd <vprintfmt+0x59>
  801671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801674:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80167b:	eb 80                	jmp    8015fd <vprintfmt+0x59>
  80167d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801680:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801683:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801687:	0f 89 70 ff ff ff    	jns    8015fd <vprintfmt+0x59>
				width = precision, precision = -1;
  80168d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801690:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801693:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80169a:	e9 5e ff ff ff       	jmp    8015fd <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80169f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016a5:	e9 53 ff ff ff       	jmp    8015fd <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ad:	8d 50 04             	lea    0x4(%eax),%edx
  8016b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8016b3:	83 ec 08             	sub    $0x8,%esp
  8016b6:	53                   	push   %ebx
  8016b7:	ff 30                	pushl  (%eax)
  8016b9:	ff d6                	call   *%esi
			break;
  8016bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016c1:	e9 04 ff ff ff       	jmp    8015ca <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c9:	8d 50 04             	lea    0x4(%eax),%edx
  8016cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8016cf:	8b 00                	mov    (%eax),%eax
  8016d1:	99                   	cltd   
  8016d2:	31 d0                	xor    %edx,%eax
  8016d4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016d6:	83 f8 0f             	cmp    $0xf,%eax
  8016d9:	7f 0b                	jg     8016e6 <vprintfmt+0x142>
  8016db:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8016e2:	85 d2                	test   %edx,%edx
  8016e4:	75 18                	jne    8016fe <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8016e6:	50                   	push   %eax
  8016e7:	68 9b 23 80 00       	push   $0x80239b
  8016ec:	53                   	push   %ebx
  8016ed:	56                   	push   %esi
  8016ee:	e8 94 fe ff ff       	call   801587 <printfmt>
  8016f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8016f9:	e9 cc fe ff ff       	jmp    8015ca <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8016fe:	52                   	push   %edx
  8016ff:	68 19 23 80 00       	push   $0x802319
  801704:	53                   	push   %ebx
  801705:	56                   	push   %esi
  801706:	e8 7c fe ff ff       	call   801587 <printfmt>
  80170b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80170e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801711:	e9 b4 fe ff ff       	jmp    8015ca <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801716:	8b 45 14             	mov    0x14(%ebp),%eax
  801719:	8d 50 04             	lea    0x4(%eax),%edx
  80171c:	89 55 14             	mov    %edx,0x14(%ebp)
  80171f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801721:	85 ff                	test   %edi,%edi
  801723:	b8 94 23 80 00       	mov    $0x802394,%eax
  801728:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80172b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80172f:	0f 8e 94 00 00 00    	jle    8017c9 <vprintfmt+0x225>
  801735:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801739:	0f 84 98 00 00 00    	je     8017d7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	ff 75 d0             	pushl  -0x30(%ebp)
  801745:	57                   	push   %edi
  801746:	e8 86 02 00 00       	call   8019d1 <strnlen>
  80174b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80174e:	29 c1                	sub    %eax,%ecx
  801750:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801753:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801756:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80175a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80175d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801760:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801762:	eb 0f                	jmp    801773 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801764:	83 ec 08             	sub    $0x8,%esp
  801767:	53                   	push   %ebx
  801768:	ff 75 e0             	pushl  -0x20(%ebp)
  80176b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80176d:	83 ef 01             	sub    $0x1,%edi
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	85 ff                	test   %edi,%edi
  801775:	7f ed                	jg     801764 <vprintfmt+0x1c0>
  801777:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80177a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80177d:	85 c9                	test   %ecx,%ecx
  80177f:	b8 00 00 00 00       	mov    $0x0,%eax
  801784:	0f 49 c1             	cmovns %ecx,%eax
  801787:	29 c1                	sub    %eax,%ecx
  801789:	89 75 08             	mov    %esi,0x8(%ebp)
  80178c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80178f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801792:	89 cb                	mov    %ecx,%ebx
  801794:	eb 4d                	jmp    8017e3 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801796:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80179a:	74 1b                	je     8017b7 <vprintfmt+0x213>
  80179c:	0f be c0             	movsbl %al,%eax
  80179f:	83 e8 20             	sub    $0x20,%eax
  8017a2:	83 f8 5e             	cmp    $0x5e,%eax
  8017a5:	76 10                	jbe    8017b7 <vprintfmt+0x213>
					putch('?', putdat);
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	ff 75 0c             	pushl  0xc(%ebp)
  8017ad:	6a 3f                	push   $0x3f
  8017af:	ff 55 08             	call   *0x8(%ebp)
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	eb 0d                	jmp    8017c4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017b7:	83 ec 08             	sub    $0x8,%esp
  8017ba:	ff 75 0c             	pushl  0xc(%ebp)
  8017bd:	52                   	push   %edx
  8017be:	ff 55 08             	call   *0x8(%ebp)
  8017c1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017c4:	83 eb 01             	sub    $0x1,%ebx
  8017c7:	eb 1a                	jmp    8017e3 <vprintfmt+0x23f>
  8017c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8017cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017d5:	eb 0c                	jmp    8017e3 <vprintfmt+0x23f>
  8017d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8017da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017e0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017e3:	83 c7 01             	add    $0x1,%edi
  8017e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017ea:	0f be d0             	movsbl %al,%edx
  8017ed:	85 d2                	test   %edx,%edx
  8017ef:	74 23                	je     801814 <vprintfmt+0x270>
  8017f1:	85 f6                	test   %esi,%esi
  8017f3:	78 a1                	js     801796 <vprintfmt+0x1f2>
  8017f5:	83 ee 01             	sub    $0x1,%esi
  8017f8:	79 9c                	jns    801796 <vprintfmt+0x1f2>
  8017fa:	89 df                	mov    %ebx,%edi
  8017fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8017ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801802:	eb 18                	jmp    80181c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801804:	83 ec 08             	sub    $0x8,%esp
  801807:	53                   	push   %ebx
  801808:	6a 20                	push   $0x20
  80180a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80180c:	83 ef 01             	sub    $0x1,%edi
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	eb 08                	jmp    80181c <vprintfmt+0x278>
  801814:	89 df                	mov    %ebx,%edi
  801816:	8b 75 08             	mov    0x8(%ebp),%esi
  801819:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80181c:	85 ff                	test   %edi,%edi
  80181e:	7f e4                	jg     801804 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801820:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801823:	e9 a2 fd ff ff       	jmp    8015ca <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801828:	83 fa 01             	cmp    $0x1,%edx
  80182b:	7e 16                	jle    801843 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80182d:	8b 45 14             	mov    0x14(%ebp),%eax
  801830:	8d 50 08             	lea    0x8(%eax),%edx
  801833:	89 55 14             	mov    %edx,0x14(%ebp)
  801836:	8b 50 04             	mov    0x4(%eax),%edx
  801839:	8b 00                	mov    (%eax),%eax
  80183b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80183e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801841:	eb 32                	jmp    801875 <vprintfmt+0x2d1>
	else if (lflag)
  801843:	85 d2                	test   %edx,%edx
  801845:	74 18                	je     80185f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801847:	8b 45 14             	mov    0x14(%ebp),%eax
  80184a:	8d 50 04             	lea    0x4(%eax),%edx
  80184d:	89 55 14             	mov    %edx,0x14(%ebp)
  801850:	8b 00                	mov    (%eax),%eax
  801852:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801855:	89 c1                	mov    %eax,%ecx
  801857:	c1 f9 1f             	sar    $0x1f,%ecx
  80185a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80185d:	eb 16                	jmp    801875 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80185f:	8b 45 14             	mov    0x14(%ebp),%eax
  801862:	8d 50 04             	lea    0x4(%eax),%edx
  801865:	89 55 14             	mov    %edx,0x14(%ebp)
  801868:	8b 00                	mov    (%eax),%eax
  80186a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80186d:	89 c1                	mov    %eax,%ecx
  80186f:	c1 f9 1f             	sar    $0x1f,%ecx
  801872:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801875:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801878:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80187b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801880:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801884:	79 74                	jns    8018fa <vprintfmt+0x356>
				putch('-', putdat);
  801886:	83 ec 08             	sub    $0x8,%esp
  801889:	53                   	push   %ebx
  80188a:	6a 2d                	push   $0x2d
  80188c:	ff d6                	call   *%esi
				num = -(long long) num;
  80188e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801891:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801894:	f7 d8                	neg    %eax
  801896:	83 d2 00             	adc    $0x0,%edx
  801899:	f7 da                	neg    %edx
  80189b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80189e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018a3:	eb 55                	jmp    8018fa <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8018a8:	e8 83 fc ff ff       	call   801530 <getuint>
			base = 10;
  8018ad:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018b2:	eb 46                	jmp    8018fa <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8018b7:	e8 74 fc ff ff       	call   801530 <getuint>
			base = 8;
  8018bc:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018c1:	eb 37                	jmp    8018fa <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018c3:	83 ec 08             	sub    $0x8,%esp
  8018c6:	53                   	push   %ebx
  8018c7:	6a 30                	push   $0x30
  8018c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8018cb:	83 c4 08             	add    $0x8,%esp
  8018ce:	53                   	push   %ebx
  8018cf:	6a 78                	push   $0x78
  8018d1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d6:	8d 50 04             	lea    0x4(%eax),%edx
  8018d9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018dc:	8b 00                	mov    (%eax),%eax
  8018de:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018e3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8018e6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8018eb:	eb 0d                	jmp    8018fa <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8018f0:	e8 3b fc ff ff       	call   801530 <getuint>
			base = 16;
  8018f5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018fa:	83 ec 0c             	sub    $0xc,%esp
  8018fd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801901:	57                   	push   %edi
  801902:	ff 75 e0             	pushl  -0x20(%ebp)
  801905:	51                   	push   %ecx
  801906:	52                   	push   %edx
  801907:	50                   	push   %eax
  801908:	89 da                	mov    %ebx,%edx
  80190a:	89 f0                	mov    %esi,%eax
  80190c:	e8 70 fb ff ff       	call   801481 <printnum>
			break;
  801911:	83 c4 20             	add    $0x20,%esp
  801914:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801917:	e9 ae fc ff ff       	jmp    8015ca <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80191c:	83 ec 08             	sub    $0x8,%esp
  80191f:	53                   	push   %ebx
  801920:	51                   	push   %ecx
  801921:	ff d6                	call   *%esi
			break;
  801923:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801926:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801929:	e9 9c fc ff ff       	jmp    8015ca <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80192e:	83 ec 08             	sub    $0x8,%esp
  801931:	53                   	push   %ebx
  801932:	6a 25                	push   $0x25
  801934:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801936:	83 c4 10             	add    $0x10,%esp
  801939:	eb 03                	jmp    80193e <vprintfmt+0x39a>
  80193b:	83 ef 01             	sub    $0x1,%edi
  80193e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801942:	75 f7                	jne    80193b <vprintfmt+0x397>
  801944:	e9 81 fc ff ff       	jmp    8015ca <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801949:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80194c:	5b                   	pop    %ebx
  80194d:	5e                   	pop    %esi
  80194e:	5f                   	pop    %edi
  80194f:	5d                   	pop    %ebp
  801950:	c3                   	ret    

00801951 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	83 ec 18             	sub    $0x18,%esp
  801957:	8b 45 08             	mov    0x8(%ebp),%eax
  80195a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80195d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801960:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801964:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801967:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80196e:	85 c0                	test   %eax,%eax
  801970:	74 26                	je     801998 <vsnprintf+0x47>
  801972:	85 d2                	test   %edx,%edx
  801974:	7e 22                	jle    801998 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801976:	ff 75 14             	pushl  0x14(%ebp)
  801979:	ff 75 10             	pushl  0x10(%ebp)
  80197c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80197f:	50                   	push   %eax
  801980:	68 6a 15 80 00       	push   $0x80156a
  801985:	e8 1a fc ff ff       	call   8015a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80198a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80198d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801990:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	eb 05                	jmp    80199d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801998:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80199d:	c9                   	leave  
  80199e:	c3                   	ret    

0080199f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019a8:	50                   	push   %eax
  8019a9:	ff 75 10             	pushl  0x10(%ebp)
  8019ac:	ff 75 0c             	pushl  0xc(%ebp)
  8019af:	ff 75 08             	pushl  0x8(%ebp)
  8019b2:	e8 9a ff ff ff       	call   801951 <vsnprintf>
	va_end(ap);

	return rc;
}
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c4:	eb 03                	jmp    8019c9 <strlen+0x10>
		n++;
  8019c6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019cd:	75 f7                	jne    8019c6 <strlen+0xd>
		n++;
	return n;
}
  8019cf:	5d                   	pop    %ebp
  8019d0:	c3                   	ret    

008019d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019da:	ba 00 00 00 00       	mov    $0x0,%edx
  8019df:	eb 03                	jmp    8019e4 <strnlen+0x13>
		n++;
  8019e1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019e4:	39 c2                	cmp    %eax,%edx
  8019e6:	74 08                	je     8019f0 <strnlen+0x1f>
  8019e8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8019ec:	75 f3                	jne    8019e1 <strnlen+0x10>
  8019ee:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8019f0:	5d                   	pop    %ebp
  8019f1:	c3                   	ret    

008019f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	53                   	push   %ebx
  8019f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8019fc:	89 c2                	mov    %eax,%edx
  8019fe:	83 c2 01             	add    $0x1,%edx
  801a01:	83 c1 01             	add    $0x1,%ecx
  801a04:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a08:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a0b:	84 db                	test   %bl,%bl
  801a0d:	75 ef                	jne    8019fe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a0f:	5b                   	pop    %ebx
  801a10:	5d                   	pop    %ebp
  801a11:	c3                   	ret    

00801a12 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	53                   	push   %ebx
  801a16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a19:	53                   	push   %ebx
  801a1a:	e8 9a ff ff ff       	call   8019b9 <strlen>
  801a1f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a22:	ff 75 0c             	pushl  0xc(%ebp)
  801a25:	01 d8                	add    %ebx,%eax
  801a27:	50                   	push   %eax
  801a28:	e8 c5 ff ff ff       	call   8019f2 <strcpy>
	return dst;
}
  801a2d:	89 d8                	mov    %ebx,%eax
  801a2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a32:	c9                   	leave  
  801a33:	c3                   	ret    

00801a34 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	56                   	push   %esi
  801a38:	53                   	push   %ebx
  801a39:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a3f:	89 f3                	mov    %esi,%ebx
  801a41:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a44:	89 f2                	mov    %esi,%edx
  801a46:	eb 0f                	jmp    801a57 <strncpy+0x23>
		*dst++ = *src;
  801a48:	83 c2 01             	add    $0x1,%edx
  801a4b:	0f b6 01             	movzbl (%ecx),%eax
  801a4e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a51:	80 39 01             	cmpb   $0x1,(%ecx)
  801a54:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a57:	39 da                	cmp    %ebx,%edx
  801a59:	75 ed                	jne    801a48 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a5b:	89 f0                	mov    %esi,%eax
  801a5d:	5b                   	pop    %ebx
  801a5e:	5e                   	pop    %esi
  801a5f:	5d                   	pop    %ebp
  801a60:	c3                   	ret    

00801a61 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
  801a66:	8b 75 08             	mov    0x8(%ebp),%esi
  801a69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6c:	8b 55 10             	mov    0x10(%ebp),%edx
  801a6f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a71:	85 d2                	test   %edx,%edx
  801a73:	74 21                	je     801a96 <strlcpy+0x35>
  801a75:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a79:	89 f2                	mov    %esi,%edx
  801a7b:	eb 09                	jmp    801a86 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a7d:	83 c2 01             	add    $0x1,%edx
  801a80:	83 c1 01             	add    $0x1,%ecx
  801a83:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a86:	39 c2                	cmp    %eax,%edx
  801a88:	74 09                	je     801a93 <strlcpy+0x32>
  801a8a:	0f b6 19             	movzbl (%ecx),%ebx
  801a8d:	84 db                	test   %bl,%bl
  801a8f:	75 ec                	jne    801a7d <strlcpy+0x1c>
  801a91:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a93:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801a96:	29 f0                	sub    %esi,%eax
}
  801a98:	5b                   	pop    %ebx
  801a99:	5e                   	pop    %esi
  801a9a:	5d                   	pop    %ebp
  801a9b:	c3                   	ret    

00801a9c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801aa5:	eb 06                	jmp    801aad <strcmp+0x11>
		p++, q++;
  801aa7:	83 c1 01             	add    $0x1,%ecx
  801aaa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801aad:	0f b6 01             	movzbl (%ecx),%eax
  801ab0:	84 c0                	test   %al,%al
  801ab2:	74 04                	je     801ab8 <strcmp+0x1c>
  801ab4:	3a 02                	cmp    (%edx),%al
  801ab6:	74 ef                	je     801aa7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ab8:	0f b6 c0             	movzbl %al,%eax
  801abb:	0f b6 12             	movzbl (%edx),%edx
  801abe:	29 d0                	sub    %edx,%eax
}
  801ac0:	5d                   	pop    %ebp
  801ac1:	c3                   	ret    

00801ac2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	53                   	push   %ebx
  801ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801acc:	89 c3                	mov    %eax,%ebx
  801ace:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ad1:	eb 06                	jmp    801ad9 <strncmp+0x17>
		n--, p++, q++;
  801ad3:	83 c0 01             	add    $0x1,%eax
  801ad6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ad9:	39 d8                	cmp    %ebx,%eax
  801adb:	74 15                	je     801af2 <strncmp+0x30>
  801add:	0f b6 08             	movzbl (%eax),%ecx
  801ae0:	84 c9                	test   %cl,%cl
  801ae2:	74 04                	je     801ae8 <strncmp+0x26>
  801ae4:	3a 0a                	cmp    (%edx),%cl
  801ae6:	74 eb                	je     801ad3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801ae8:	0f b6 00             	movzbl (%eax),%eax
  801aeb:	0f b6 12             	movzbl (%edx),%edx
  801aee:	29 d0                	sub    %edx,%eax
  801af0:	eb 05                	jmp    801af7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801af2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801af7:	5b                   	pop    %ebx
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	8b 45 08             	mov    0x8(%ebp),%eax
  801b00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b04:	eb 07                	jmp    801b0d <strchr+0x13>
		if (*s == c)
  801b06:	38 ca                	cmp    %cl,%dl
  801b08:	74 0f                	je     801b19 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b0a:	83 c0 01             	add    $0x1,%eax
  801b0d:	0f b6 10             	movzbl (%eax),%edx
  801b10:	84 d2                	test   %dl,%dl
  801b12:	75 f2                	jne    801b06 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b19:	5d                   	pop    %ebp
  801b1a:	c3                   	ret    

00801b1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b25:	eb 03                	jmp    801b2a <strfind+0xf>
  801b27:	83 c0 01             	add    $0x1,%eax
  801b2a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b2d:	38 ca                	cmp    %cl,%dl
  801b2f:	74 04                	je     801b35 <strfind+0x1a>
  801b31:	84 d2                	test   %dl,%dl
  801b33:	75 f2                	jne    801b27 <strfind+0xc>
			break;
	return (char *) s;
}
  801b35:	5d                   	pop    %ebp
  801b36:	c3                   	ret    

00801b37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	57                   	push   %edi
  801b3b:	56                   	push   %esi
  801b3c:	53                   	push   %ebx
  801b3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b43:	85 c9                	test   %ecx,%ecx
  801b45:	74 36                	je     801b7d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b4d:	75 28                	jne    801b77 <memset+0x40>
  801b4f:	f6 c1 03             	test   $0x3,%cl
  801b52:	75 23                	jne    801b77 <memset+0x40>
		c &= 0xFF;
  801b54:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b58:	89 d3                	mov    %edx,%ebx
  801b5a:	c1 e3 08             	shl    $0x8,%ebx
  801b5d:	89 d6                	mov    %edx,%esi
  801b5f:	c1 e6 18             	shl    $0x18,%esi
  801b62:	89 d0                	mov    %edx,%eax
  801b64:	c1 e0 10             	shl    $0x10,%eax
  801b67:	09 f0                	or     %esi,%eax
  801b69:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b6b:	89 d8                	mov    %ebx,%eax
  801b6d:	09 d0                	or     %edx,%eax
  801b6f:	c1 e9 02             	shr    $0x2,%ecx
  801b72:	fc                   	cld    
  801b73:	f3 ab                	rep stos %eax,%es:(%edi)
  801b75:	eb 06                	jmp    801b7d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7a:	fc                   	cld    
  801b7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b7d:	89 f8                	mov    %edi,%eax
  801b7f:	5b                   	pop    %ebx
  801b80:	5e                   	pop    %esi
  801b81:	5f                   	pop    %edi
  801b82:	5d                   	pop    %ebp
  801b83:	c3                   	ret    

00801b84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	57                   	push   %edi
  801b88:	56                   	push   %esi
  801b89:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b92:	39 c6                	cmp    %eax,%esi
  801b94:	73 35                	jae    801bcb <memmove+0x47>
  801b96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b99:	39 d0                	cmp    %edx,%eax
  801b9b:	73 2e                	jae    801bcb <memmove+0x47>
		s += n;
		d += n;
  801b9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ba0:	89 d6                	mov    %edx,%esi
  801ba2:	09 fe                	or     %edi,%esi
  801ba4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801baa:	75 13                	jne    801bbf <memmove+0x3b>
  801bac:	f6 c1 03             	test   $0x3,%cl
  801baf:	75 0e                	jne    801bbf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bb1:	83 ef 04             	sub    $0x4,%edi
  801bb4:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bb7:	c1 e9 02             	shr    $0x2,%ecx
  801bba:	fd                   	std    
  801bbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bbd:	eb 09                	jmp    801bc8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bbf:	83 ef 01             	sub    $0x1,%edi
  801bc2:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bc5:	fd                   	std    
  801bc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bc8:	fc                   	cld    
  801bc9:	eb 1d                	jmp    801be8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bcb:	89 f2                	mov    %esi,%edx
  801bcd:	09 c2                	or     %eax,%edx
  801bcf:	f6 c2 03             	test   $0x3,%dl
  801bd2:	75 0f                	jne    801be3 <memmove+0x5f>
  801bd4:	f6 c1 03             	test   $0x3,%cl
  801bd7:	75 0a                	jne    801be3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801bd9:	c1 e9 02             	shr    $0x2,%ecx
  801bdc:	89 c7                	mov    %eax,%edi
  801bde:	fc                   	cld    
  801bdf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801be1:	eb 05                	jmp    801be8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801be3:	89 c7                	mov    %eax,%edi
  801be5:	fc                   	cld    
  801be6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801be8:	5e                   	pop    %esi
  801be9:	5f                   	pop    %edi
  801bea:	5d                   	pop    %ebp
  801beb:	c3                   	ret    

00801bec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801bef:	ff 75 10             	pushl  0x10(%ebp)
  801bf2:	ff 75 0c             	pushl  0xc(%ebp)
  801bf5:	ff 75 08             	pushl  0x8(%ebp)
  801bf8:	e8 87 ff ff ff       	call   801b84 <memmove>
}
  801bfd:	c9                   	leave  
  801bfe:	c3                   	ret    

00801bff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	56                   	push   %esi
  801c03:	53                   	push   %ebx
  801c04:	8b 45 08             	mov    0x8(%ebp),%eax
  801c07:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c0a:	89 c6                	mov    %eax,%esi
  801c0c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c0f:	eb 1a                	jmp    801c2b <memcmp+0x2c>
		if (*s1 != *s2)
  801c11:	0f b6 08             	movzbl (%eax),%ecx
  801c14:	0f b6 1a             	movzbl (%edx),%ebx
  801c17:	38 d9                	cmp    %bl,%cl
  801c19:	74 0a                	je     801c25 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c1b:	0f b6 c1             	movzbl %cl,%eax
  801c1e:	0f b6 db             	movzbl %bl,%ebx
  801c21:	29 d8                	sub    %ebx,%eax
  801c23:	eb 0f                	jmp    801c34 <memcmp+0x35>
		s1++, s2++;
  801c25:	83 c0 01             	add    $0x1,%eax
  801c28:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c2b:	39 f0                	cmp    %esi,%eax
  801c2d:	75 e2                	jne    801c11 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c34:	5b                   	pop    %ebx
  801c35:	5e                   	pop    %esi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    

00801c38 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	53                   	push   %ebx
  801c3c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c3f:	89 c1                	mov    %eax,%ecx
  801c41:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c44:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c48:	eb 0a                	jmp    801c54 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c4a:	0f b6 10             	movzbl (%eax),%edx
  801c4d:	39 da                	cmp    %ebx,%edx
  801c4f:	74 07                	je     801c58 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c51:	83 c0 01             	add    $0x1,%eax
  801c54:	39 c8                	cmp    %ecx,%eax
  801c56:	72 f2                	jb     801c4a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c58:	5b                   	pop    %ebx
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	57                   	push   %edi
  801c5f:	56                   	push   %esi
  801c60:	53                   	push   %ebx
  801c61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c67:	eb 03                	jmp    801c6c <strtol+0x11>
		s++;
  801c69:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c6c:	0f b6 01             	movzbl (%ecx),%eax
  801c6f:	3c 20                	cmp    $0x20,%al
  801c71:	74 f6                	je     801c69 <strtol+0xe>
  801c73:	3c 09                	cmp    $0x9,%al
  801c75:	74 f2                	je     801c69 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c77:	3c 2b                	cmp    $0x2b,%al
  801c79:	75 0a                	jne    801c85 <strtol+0x2a>
		s++;
  801c7b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c7e:	bf 00 00 00 00       	mov    $0x0,%edi
  801c83:	eb 11                	jmp    801c96 <strtol+0x3b>
  801c85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c8a:	3c 2d                	cmp    $0x2d,%al
  801c8c:	75 08                	jne    801c96 <strtol+0x3b>
		s++, neg = 1;
  801c8e:	83 c1 01             	add    $0x1,%ecx
  801c91:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c96:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801c9c:	75 15                	jne    801cb3 <strtol+0x58>
  801c9e:	80 39 30             	cmpb   $0x30,(%ecx)
  801ca1:	75 10                	jne    801cb3 <strtol+0x58>
  801ca3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ca7:	75 7c                	jne    801d25 <strtol+0xca>
		s += 2, base = 16;
  801ca9:	83 c1 02             	add    $0x2,%ecx
  801cac:	bb 10 00 00 00       	mov    $0x10,%ebx
  801cb1:	eb 16                	jmp    801cc9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801cb3:	85 db                	test   %ebx,%ebx
  801cb5:	75 12                	jne    801cc9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cb7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cbc:	80 39 30             	cmpb   $0x30,(%ecx)
  801cbf:	75 08                	jne    801cc9 <strtol+0x6e>
		s++, base = 8;
  801cc1:	83 c1 01             	add    $0x1,%ecx
  801cc4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cce:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cd1:	0f b6 11             	movzbl (%ecx),%edx
  801cd4:	8d 72 d0             	lea    -0x30(%edx),%esi
  801cd7:	89 f3                	mov    %esi,%ebx
  801cd9:	80 fb 09             	cmp    $0x9,%bl
  801cdc:	77 08                	ja     801ce6 <strtol+0x8b>
			dig = *s - '0';
  801cde:	0f be d2             	movsbl %dl,%edx
  801ce1:	83 ea 30             	sub    $0x30,%edx
  801ce4:	eb 22                	jmp    801d08 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ce6:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ce9:	89 f3                	mov    %esi,%ebx
  801ceb:	80 fb 19             	cmp    $0x19,%bl
  801cee:	77 08                	ja     801cf8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801cf0:	0f be d2             	movsbl %dl,%edx
  801cf3:	83 ea 57             	sub    $0x57,%edx
  801cf6:	eb 10                	jmp    801d08 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801cf8:	8d 72 bf             	lea    -0x41(%edx),%esi
  801cfb:	89 f3                	mov    %esi,%ebx
  801cfd:	80 fb 19             	cmp    $0x19,%bl
  801d00:	77 16                	ja     801d18 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d02:	0f be d2             	movsbl %dl,%edx
  801d05:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d08:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d0b:	7d 0b                	jge    801d18 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d0d:	83 c1 01             	add    $0x1,%ecx
  801d10:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d14:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d16:	eb b9                	jmp    801cd1 <strtol+0x76>

	if (endptr)
  801d18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d1c:	74 0d                	je     801d2b <strtol+0xd0>
		*endptr = (char *) s;
  801d1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d21:	89 0e                	mov    %ecx,(%esi)
  801d23:	eb 06                	jmp    801d2b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d25:	85 db                	test   %ebx,%ebx
  801d27:	74 98                	je     801cc1 <strtol+0x66>
  801d29:	eb 9e                	jmp    801cc9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d2b:	89 c2                	mov    %eax,%edx
  801d2d:	f7 da                	neg    %edx
  801d2f:	85 ff                	test   %edi,%edi
  801d31:	0f 45 c2             	cmovne %edx,%eax
}
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    

00801d39 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d3f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d46:	75 2a                	jne    801d72 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d48:	83 ec 04             	sub    $0x4,%esp
  801d4b:	6a 07                	push   $0x7
  801d4d:	68 00 f0 bf ee       	push   $0xeebff000
  801d52:	6a 00                	push   $0x0
  801d54:	e8 2e e4 ff ff       	call   800187 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	79 12                	jns    801d72 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d60:	50                   	push   %eax
  801d61:	68 80 26 80 00       	push   $0x802680
  801d66:	6a 23                	push   $0x23
  801d68:	68 84 26 80 00       	push   $0x802684
  801d6d:	e8 22 f6 ff ff       	call   801394 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d72:	8b 45 08             	mov    0x8(%ebp),%eax
  801d75:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d7a:	83 ec 08             	sub    $0x8,%esp
  801d7d:	68 a4 1d 80 00       	push   $0x801da4
  801d82:	6a 00                	push   $0x0
  801d84:	e8 49 e5 ff ff       	call   8002d2 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	79 12                	jns    801da2 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801d90:	50                   	push   %eax
  801d91:	68 80 26 80 00       	push   $0x802680
  801d96:	6a 2c                	push   $0x2c
  801d98:	68 84 26 80 00       	push   $0x802684
  801d9d:	e8 f2 f5 ff ff       	call   801394 <_panic>
	}
}
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    

00801da4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801da4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801da5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801daa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dac:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801daf:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801db3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801db8:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dbc:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dbe:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dc1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dc2:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dc5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dc6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dc7:	c3                   	ret    

00801dc8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	56                   	push   %esi
  801dcc:	53                   	push   %ebx
  801dcd:	8b 75 08             	mov    0x8(%ebp),%esi
  801dd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	75 12                	jne    801dec <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801dda:	83 ec 0c             	sub    $0xc,%esp
  801ddd:	68 00 00 c0 ee       	push   $0xeec00000
  801de2:	e8 50 e5 ff ff       	call   800337 <sys_ipc_recv>
  801de7:	83 c4 10             	add    $0x10,%esp
  801dea:	eb 0c                	jmp    801df8 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801dec:	83 ec 0c             	sub    $0xc,%esp
  801def:	50                   	push   %eax
  801df0:	e8 42 e5 ff ff       	call   800337 <sys_ipc_recv>
  801df5:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801df8:	85 f6                	test   %esi,%esi
  801dfa:	0f 95 c1             	setne  %cl
  801dfd:	85 db                	test   %ebx,%ebx
  801dff:	0f 95 c2             	setne  %dl
  801e02:	84 d1                	test   %dl,%cl
  801e04:	74 09                	je     801e0f <ipc_recv+0x47>
  801e06:	89 c2                	mov    %eax,%edx
  801e08:	c1 ea 1f             	shr    $0x1f,%edx
  801e0b:	84 d2                	test   %dl,%dl
  801e0d:	75 2a                	jne    801e39 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e0f:	85 f6                	test   %esi,%esi
  801e11:	74 0d                	je     801e20 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e13:	a1 04 40 80 00       	mov    0x804004,%eax
  801e18:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e1e:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e20:	85 db                	test   %ebx,%ebx
  801e22:	74 0d                	je     801e31 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e24:	a1 04 40 80 00       	mov    0x804004,%eax
  801e29:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e2f:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e31:	a1 04 40 80 00       	mov    0x804004,%eax
  801e36:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801e39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3c:	5b                   	pop    %ebx
  801e3d:	5e                   	pop    %esi
  801e3e:	5d                   	pop    %ebp
  801e3f:	c3                   	ret    

00801e40 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	57                   	push   %edi
  801e44:	56                   	push   %esi
  801e45:	53                   	push   %ebx
  801e46:	83 ec 0c             	sub    $0xc,%esp
  801e49:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e52:	85 db                	test   %ebx,%ebx
  801e54:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e59:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e5c:	ff 75 14             	pushl  0x14(%ebp)
  801e5f:	53                   	push   %ebx
  801e60:	56                   	push   %esi
  801e61:	57                   	push   %edi
  801e62:	e8 ad e4 ff ff       	call   800314 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e67:	89 c2                	mov    %eax,%edx
  801e69:	c1 ea 1f             	shr    $0x1f,%edx
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	84 d2                	test   %dl,%dl
  801e71:	74 17                	je     801e8a <ipc_send+0x4a>
  801e73:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e76:	74 12                	je     801e8a <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e78:	50                   	push   %eax
  801e79:	68 92 26 80 00       	push   $0x802692
  801e7e:	6a 47                	push   $0x47
  801e80:	68 a0 26 80 00       	push   $0x8026a0
  801e85:	e8 0a f5 ff ff       	call   801394 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e8a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e8d:	75 07                	jne    801e96 <ipc_send+0x56>
			sys_yield();
  801e8f:	e8 d4 e2 ff ff       	call   800168 <sys_yield>
  801e94:	eb c6                	jmp    801e5c <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801e96:	85 c0                	test   %eax,%eax
  801e98:	75 c2                	jne    801e5c <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801e9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9d:	5b                   	pop    %ebx
  801e9e:	5e                   	pop    %esi
  801e9f:	5f                   	pop    %edi
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    

00801ea2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ea8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ead:	89 c2                	mov    %eax,%edx
  801eaf:	c1 e2 07             	shl    $0x7,%edx
  801eb2:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801eb9:	8b 52 5c             	mov    0x5c(%edx),%edx
  801ebc:	39 ca                	cmp    %ecx,%edx
  801ebe:	75 11                	jne    801ed1 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801ec0:	89 c2                	mov    %eax,%edx
  801ec2:	c1 e2 07             	shl    $0x7,%edx
  801ec5:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801ecc:	8b 40 54             	mov    0x54(%eax),%eax
  801ecf:	eb 0f                	jmp    801ee0 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ed1:	83 c0 01             	add    $0x1,%eax
  801ed4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ed9:	75 d2                	jne    801ead <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801edb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ee0:	5d                   	pop    %ebp
  801ee1:	c3                   	ret    

00801ee2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ee8:	89 d0                	mov    %edx,%eax
  801eea:	c1 e8 16             	shr    $0x16,%eax
  801eed:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ef4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef9:	f6 c1 01             	test   $0x1,%cl
  801efc:	74 1d                	je     801f1b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801efe:	c1 ea 0c             	shr    $0xc,%edx
  801f01:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f08:	f6 c2 01             	test   $0x1,%dl
  801f0b:	74 0e                	je     801f1b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f0d:	c1 ea 0c             	shr    $0xc,%edx
  801f10:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f17:	ef 
  801f18:	0f b7 c0             	movzwl %ax,%eax
}
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    
  801f1d:	66 90                	xchg   %ax,%ax
  801f1f:	90                   	nop

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
