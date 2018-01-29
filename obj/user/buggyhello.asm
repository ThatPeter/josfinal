
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
  80003d:	e8 88 00 00 00       	call   8000ca <sys_cputs>
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
  800052:	e8 f1 00 00 00       	call   800148 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x30>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 2a 00 00 00       	call   8000b0 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800096:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  80009b:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80009d:	e8 a6 00 00 00       	call   800148 <sys_getenvid>
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	50                   	push   %eax
  8000a6:	e8 ec 02 00 00       	call   800397 <sys_thread_free>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b6:	e8 04 08 00 00       	call   8008bf <close_all>
	sys_env_destroy(0);
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	6a 00                	push   $0x0
  8000c0:	e8 42 00 00 00       	call   800107 <sys_env_destroy>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	89 c3                	mov    %eax,%ebx
  8000dd:	89 c7                	mov    %eax,%edi
  8000df:	89 c6                	mov    %eax,%esi
  8000e1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5f                   	pop    %edi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	57                   	push   %edi
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f8:	89 d1                	mov    %edx,%ecx
  8000fa:	89 d3                	mov    %edx,%ebx
  8000fc:	89 d7                	mov    %edx,%edi
  8000fe:	89 d6                	mov    %edx,%esi
  800100:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5f                   	pop    %edi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	57                   	push   %edi
  80010b:	56                   	push   %esi
  80010c:	53                   	push   %ebx
  80010d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800110:	b9 00 00 00 00       	mov    $0x0,%ecx
  800115:	b8 03 00 00 00       	mov    $0x3,%eax
  80011a:	8b 55 08             	mov    0x8(%ebp),%edx
  80011d:	89 cb                	mov    %ecx,%ebx
  80011f:	89 cf                	mov    %ecx,%edi
  800121:	89 ce                	mov    %ecx,%esi
  800123:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800125:	85 c0                	test   %eax,%eax
  800127:	7e 17                	jle    800140 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	50                   	push   %eax
  80012d:	6a 03                	push   $0x3
  80012f:	68 2a 22 80 00       	push   $0x80222a
  800134:	6a 23                	push   $0x23
  800136:	68 47 22 80 00       	push   $0x802247
  80013b:	e8 b0 12 00 00       	call   8013f0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800140:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800143:	5b                   	pop    %ebx
  800144:	5e                   	pop    %esi
  800145:	5f                   	pop    %edi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	57                   	push   %edi
  80014c:	56                   	push   %esi
  80014d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014e:	ba 00 00 00 00       	mov    $0x0,%edx
  800153:	b8 02 00 00 00       	mov    $0x2,%eax
  800158:	89 d1                	mov    %edx,%ecx
  80015a:	89 d3                	mov    %edx,%ebx
  80015c:	89 d7                	mov    %edx,%edi
  80015e:	89 d6                	mov    %edx,%esi
  800160:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800162:	5b                   	pop    %ebx
  800163:	5e                   	pop    %esi
  800164:	5f                   	pop    %edi
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    

00800167 <sys_yield>:

void
sys_yield(void)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016d:	ba 00 00 00 00       	mov    $0x0,%edx
  800172:	b8 0b 00 00 00       	mov    $0xb,%eax
  800177:	89 d1                	mov    %edx,%ecx
  800179:	89 d3                	mov    %edx,%ebx
  80017b:	89 d7                	mov    %edx,%edi
  80017d:	89 d6                	mov    %edx,%esi
  80017f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800181:	5b                   	pop    %ebx
  800182:	5e                   	pop    %esi
  800183:	5f                   	pop    %edi
  800184:	5d                   	pop    %ebp
  800185:	c3                   	ret    

00800186 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	57                   	push   %edi
  80018a:	56                   	push   %esi
  80018b:	53                   	push   %ebx
  80018c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018f:	be 00 00 00 00       	mov    $0x0,%esi
  800194:	b8 04 00 00 00       	mov    $0x4,%eax
  800199:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019c:	8b 55 08             	mov    0x8(%ebp),%edx
  80019f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a2:	89 f7                	mov    %esi,%edi
  8001a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a6:	85 c0                	test   %eax,%eax
  8001a8:	7e 17                	jle    8001c1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001aa:	83 ec 0c             	sub    $0xc,%esp
  8001ad:	50                   	push   %eax
  8001ae:	6a 04                	push   $0x4
  8001b0:	68 2a 22 80 00       	push   $0x80222a
  8001b5:	6a 23                	push   $0x23
  8001b7:	68 47 22 80 00       	push   $0x802247
  8001bc:	e8 2f 12 00 00       	call   8013f0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5f                   	pop    %edi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    

008001c9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001da:	8b 55 08             	mov    0x8(%ebp),%edx
  8001dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e8:	85 c0                	test   %eax,%eax
  8001ea:	7e 17                	jle    800203 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	50                   	push   %eax
  8001f0:	6a 05                	push   $0x5
  8001f2:	68 2a 22 80 00       	push   $0x80222a
  8001f7:	6a 23                	push   $0x23
  8001f9:	68 47 22 80 00       	push   $0x802247
  8001fe:	e8 ed 11 00 00       	call   8013f0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800203:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800206:	5b                   	pop    %ebx
  800207:	5e                   	pop    %esi
  800208:	5f                   	pop    %edi
  800209:	5d                   	pop    %ebp
  80020a:	c3                   	ret    

0080020b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	57                   	push   %edi
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800214:	bb 00 00 00 00       	mov    $0x0,%ebx
  800219:	b8 06 00 00 00       	mov    $0x6,%eax
  80021e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800221:	8b 55 08             	mov    0x8(%ebp),%edx
  800224:	89 df                	mov    %ebx,%edi
  800226:	89 de                	mov    %ebx,%esi
  800228:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80022a:	85 c0                	test   %eax,%eax
  80022c:	7e 17                	jle    800245 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022e:	83 ec 0c             	sub    $0xc,%esp
  800231:	50                   	push   %eax
  800232:	6a 06                	push   $0x6
  800234:	68 2a 22 80 00       	push   $0x80222a
  800239:	6a 23                	push   $0x23
  80023b:	68 47 22 80 00       	push   $0x802247
  800240:	e8 ab 11 00 00       	call   8013f0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800245:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800248:	5b                   	pop    %ebx
  800249:	5e                   	pop    %esi
  80024a:	5f                   	pop    %edi
  80024b:	5d                   	pop    %ebp
  80024c:	c3                   	ret    

0080024d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80024d:	55                   	push   %ebp
  80024e:	89 e5                	mov    %esp,%ebp
  800250:	57                   	push   %edi
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
  800253:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	b8 08 00 00 00       	mov    $0x8,%eax
  800260:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800263:	8b 55 08             	mov    0x8(%ebp),%edx
  800266:	89 df                	mov    %ebx,%edi
  800268:	89 de                	mov    %ebx,%esi
  80026a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80026c:	85 c0                	test   %eax,%eax
  80026e:	7e 17                	jle    800287 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	50                   	push   %eax
  800274:	6a 08                	push   $0x8
  800276:	68 2a 22 80 00       	push   $0x80222a
  80027b:	6a 23                	push   $0x23
  80027d:	68 47 22 80 00       	push   $0x802247
  800282:	e8 69 11 00 00       	call   8013f0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	57                   	push   %edi
  800293:	56                   	push   %esi
  800294:	53                   	push   %ebx
  800295:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029d:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a8:	89 df                	mov    %ebx,%edi
  8002aa:	89 de                	mov    %ebx,%esi
  8002ac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ae:	85 c0                	test   %eax,%eax
  8002b0:	7e 17                	jle    8002c9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b2:	83 ec 0c             	sub    $0xc,%esp
  8002b5:	50                   	push   %eax
  8002b6:	6a 09                	push   $0x9
  8002b8:	68 2a 22 80 00       	push   $0x80222a
  8002bd:	6a 23                	push   $0x23
  8002bf:	68 47 22 80 00       	push   $0x802247
  8002c4:	e8 27 11 00 00       	call   8013f0 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cc:	5b                   	pop    %ebx
  8002cd:	5e                   	pop    %esi
  8002ce:	5f                   	pop    %edi
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	57                   	push   %edi
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
  8002d7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ea:	89 df                	mov    %ebx,%edi
  8002ec:	89 de                	mov    %ebx,%esi
  8002ee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f0:	85 c0                	test   %eax,%eax
  8002f2:	7e 17                	jle    80030b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	50                   	push   %eax
  8002f8:	6a 0a                	push   $0xa
  8002fa:	68 2a 22 80 00       	push   $0x80222a
  8002ff:	6a 23                	push   $0x23
  800301:	68 47 22 80 00       	push   $0x802247
  800306:	e8 e5 10 00 00       	call   8013f0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80030b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800319:	be 00 00 00 00       	mov    $0x0,%esi
  80031e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800323:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800331:	5b                   	pop    %ebx
  800332:	5e                   	pop    %esi
  800333:	5f                   	pop    %edi
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	57                   	push   %edi
  80033a:	56                   	push   %esi
  80033b:	53                   	push   %ebx
  80033c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800344:	b8 0d 00 00 00       	mov    $0xd,%eax
  800349:	8b 55 08             	mov    0x8(%ebp),%edx
  80034c:	89 cb                	mov    %ecx,%ebx
  80034e:	89 cf                	mov    %ecx,%edi
  800350:	89 ce                	mov    %ecx,%esi
  800352:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800354:	85 c0                	test   %eax,%eax
  800356:	7e 17                	jle    80036f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	50                   	push   %eax
  80035c:	6a 0d                	push   $0xd
  80035e:	68 2a 22 80 00       	push   $0x80222a
  800363:	6a 23                	push   $0x23
  800365:	68 47 22 80 00       	push   $0x802247
  80036a:	e8 81 10 00 00       	call   8013f0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800372:	5b                   	pop    %ebx
  800373:	5e                   	pop    %esi
  800374:	5f                   	pop    %edi
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	57                   	push   %edi
  80037b:	56                   	push   %esi
  80037c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800382:	b8 0e 00 00 00       	mov    $0xe,%eax
  800387:	8b 55 08             	mov    0x8(%ebp),%edx
  80038a:	89 cb                	mov    %ecx,%ebx
  80038c:	89 cf                	mov    %ecx,%edi
  80038e:	89 ce                	mov    %ecx,%esi
  800390:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a2:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003aa:	89 cb                	mov    %ecx,%ebx
  8003ac:	89 cf                	mov    %ecx,%edi
  8003ae:	89 ce                	mov    %ecx,%esi
  8003b0:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003b2:	5b                   	pop    %ebx
  8003b3:	5e                   	pop    %esi
  8003b4:	5f                   	pop    %edi
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	57                   	push   %edi
  8003bb:	56                   	push   %esi
  8003bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c2:	b8 10 00 00 00       	mov    $0x10,%eax
  8003c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ca:	89 cb                	mov    %ecx,%ebx
  8003cc:	89 cf                	mov    %ecx,%edi
  8003ce:	89 ce                	mov    %ecx,%esi
  8003d0:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  8003d2:	5b                   	pop    %ebx
  8003d3:	5e                   	pop    %esi
  8003d4:	5f                   	pop    %edi
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	53                   	push   %ebx
  8003db:	83 ec 04             	sub    $0x4,%esp
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003e1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003e3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003e7:	74 11                	je     8003fa <pgfault+0x23>
  8003e9:	89 d8                	mov    %ebx,%eax
  8003eb:	c1 e8 0c             	shr    $0xc,%eax
  8003ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003f5:	f6 c4 08             	test   $0x8,%ah
  8003f8:	75 14                	jne    80040e <pgfault+0x37>
		panic("faulting access");
  8003fa:	83 ec 04             	sub    $0x4,%esp
  8003fd:	68 55 22 80 00       	push   $0x802255
  800402:	6a 1e                	push   $0x1e
  800404:	68 65 22 80 00       	push   $0x802265
  800409:	e8 e2 0f 00 00       	call   8013f0 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  80040e:	83 ec 04             	sub    $0x4,%esp
  800411:	6a 07                	push   $0x7
  800413:	68 00 f0 7f 00       	push   $0x7ff000
  800418:	6a 00                	push   $0x0
  80041a:	e8 67 fd ff ff       	call   800186 <sys_page_alloc>
	if (r < 0) {
  80041f:	83 c4 10             	add    $0x10,%esp
  800422:	85 c0                	test   %eax,%eax
  800424:	79 12                	jns    800438 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800426:	50                   	push   %eax
  800427:	68 70 22 80 00       	push   $0x802270
  80042c:	6a 2c                	push   $0x2c
  80042e:	68 65 22 80 00       	push   $0x802265
  800433:	e8 b8 0f 00 00       	call   8013f0 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800438:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80043e:	83 ec 04             	sub    $0x4,%esp
  800441:	68 00 10 00 00       	push   $0x1000
  800446:	53                   	push   %ebx
  800447:	68 00 f0 7f 00       	push   $0x7ff000
  80044c:	e8 f7 17 00 00       	call   801c48 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800451:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800458:	53                   	push   %ebx
  800459:	6a 00                	push   $0x0
  80045b:	68 00 f0 7f 00       	push   $0x7ff000
  800460:	6a 00                	push   $0x0
  800462:	e8 62 fd ff ff       	call   8001c9 <sys_page_map>
	if (r < 0) {
  800467:	83 c4 20             	add    $0x20,%esp
  80046a:	85 c0                	test   %eax,%eax
  80046c:	79 12                	jns    800480 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80046e:	50                   	push   %eax
  80046f:	68 70 22 80 00       	push   $0x802270
  800474:	6a 33                	push   $0x33
  800476:	68 65 22 80 00       	push   $0x802265
  80047b:	e8 70 0f 00 00       	call   8013f0 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	68 00 f0 7f 00       	push   $0x7ff000
  800488:	6a 00                	push   $0x0
  80048a:	e8 7c fd ff ff       	call   80020b <sys_page_unmap>
	if (r < 0) {
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	85 c0                	test   %eax,%eax
  800494:	79 12                	jns    8004a8 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800496:	50                   	push   %eax
  800497:	68 70 22 80 00       	push   $0x802270
  80049c:	6a 37                	push   $0x37
  80049e:	68 65 22 80 00       	push   $0x802265
  8004a3:	e8 48 0f 00 00       	call   8013f0 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8004a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ab:	c9                   	leave  
  8004ac:	c3                   	ret    

008004ad <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8004ad:	55                   	push   %ebp
  8004ae:	89 e5                	mov    %esp,%ebp
  8004b0:	57                   	push   %edi
  8004b1:	56                   	push   %esi
  8004b2:	53                   	push   %ebx
  8004b3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8004b6:	68 d7 03 80 00       	push   $0x8003d7
  8004bb:	e8 d5 18 00 00       	call   801d95 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004c0:	b8 07 00 00 00       	mov    $0x7,%eax
  8004c5:	cd 30                	int    $0x30
  8004c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	79 17                	jns    8004e8 <fork+0x3b>
		panic("fork fault %e");
  8004d1:	83 ec 04             	sub    $0x4,%esp
  8004d4:	68 89 22 80 00       	push   $0x802289
  8004d9:	68 84 00 00 00       	push   $0x84
  8004de:	68 65 22 80 00       	push   $0x802265
  8004e3:	e8 08 0f 00 00       	call   8013f0 <_panic>
  8004e8:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ee:	75 24                	jne    800514 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004f0:	e8 53 fc ff ff       	call   800148 <sys_getenvid>
  8004f5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004fa:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800500:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800505:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80050a:	b8 00 00 00 00       	mov    $0x0,%eax
  80050f:	e9 64 01 00 00       	jmp    800678 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800514:	83 ec 04             	sub    $0x4,%esp
  800517:	6a 07                	push   $0x7
  800519:	68 00 f0 bf ee       	push   $0xeebff000
  80051e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800521:	e8 60 fc ff ff       	call   800186 <sys_page_alloc>
  800526:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80052e:	89 d8                	mov    %ebx,%eax
  800530:	c1 e8 16             	shr    $0x16,%eax
  800533:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80053a:	a8 01                	test   $0x1,%al
  80053c:	0f 84 fc 00 00 00    	je     80063e <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800542:	89 d8                	mov    %ebx,%eax
  800544:	c1 e8 0c             	shr    $0xc,%eax
  800547:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80054e:	f6 c2 01             	test   $0x1,%dl
  800551:	0f 84 e7 00 00 00    	je     80063e <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800557:	89 c6                	mov    %eax,%esi
  800559:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80055c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800563:	f6 c6 04             	test   $0x4,%dh
  800566:	74 39                	je     8005a1 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800568:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80056f:	83 ec 0c             	sub    $0xc,%esp
  800572:	25 07 0e 00 00       	and    $0xe07,%eax
  800577:	50                   	push   %eax
  800578:	56                   	push   %esi
  800579:	57                   	push   %edi
  80057a:	56                   	push   %esi
  80057b:	6a 00                	push   $0x0
  80057d:	e8 47 fc ff ff       	call   8001c9 <sys_page_map>
		if (r < 0) {
  800582:	83 c4 20             	add    $0x20,%esp
  800585:	85 c0                	test   %eax,%eax
  800587:	0f 89 b1 00 00 00    	jns    80063e <fork+0x191>
		    	panic("sys page map fault %e");
  80058d:	83 ec 04             	sub    $0x4,%esp
  800590:	68 97 22 80 00       	push   $0x802297
  800595:	6a 54                	push   $0x54
  800597:	68 65 22 80 00       	push   $0x802265
  80059c:	e8 4f 0e 00 00       	call   8013f0 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8005a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a8:	f6 c2 02             	test   $0x2,%dl
  8005ab:	75 0c                	jne    8005b9 <fork+0x10c>
  8005ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b4:	f6 c4 08             	test   $0x8,%ah
  8005b7:	74 5b                	je     800614 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	68 05 08 00 00       	push   $0x805
  8005c1:	56                   	push   %esi
  8005c2:	57                   	push   %edi
  8005c3:	56                   	push   %esi
  8005c4:	6a 00                	push   $0x0
  8005c6:	e8 fe fb ff ff       	call   8001c9 <sys_page_map>
		if (r < 0) {
  8005cb:	83 c4 20             	add    $0x20,%esp
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	79 14                	jns    8005e6 <fork+0x139>
		    	panic("sys page map fault %e");
  8005d2:	83 ec 04             	sub    $0x4,%esp
  8005d5:	68 97 22 80 00       	push   $0x802297
  8005da:	6a 5b                	push   $0x5b
  8005dc:	68 65 22 80 00       	push   $0x802265
  8005e1:	e8 0a 0e 00 00       	call   8013f0 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005e6:	83 ec 0c             	sub    $0xc,%esp
  8005e9:	68 05 08 00 00       	push   $0x805
  8005ee:	56                   	push   %esi
  8005ef:	6a 00                	push   $0x0
  8005f1:	56                   	push   %esi
  8005f2:	6a 00                	push   $0x0
  8005f4:	e8 d0 fb ff ff       	call   8001c9 <sys_page_map>
		if (r < 0) {
  8005f9:	83 c4 20             	add    $0x20,%esp
  8005fc:	85 c0                	test   %eax,%eax
  8005fe:	79 3e                	jns    80063e <fork+0x191>
		    	panic("sys page map fault %e");
  800600:	83 ec 04             	sub    $0x4,%esp
  800603:	68 97 22 80 00       	push   $0x802297
  800608:	6a 5f                	push   $0x5f
  80060a:	68 65 22 80 00       	push   $0x802265
  80060f:	e8 dc 0d 00 00       	call   8013f0 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800614:	83 ec 0c             	sub    $0xc,%esp
  800617:	6a 05                	push   $0x5
  800619:	56                   	push   %esi
  80061a:	57                   	push   %edi
  80061b:	56                   	push   %esi
  80061c:	6a 00                	push   $0x0
  80061e:	e8 a6 fb ff ff       	call   8001c9 <sys_page_map>
		if (r < 0) {
  800623:	83 c4 20             	add    $0x20,%esp
  800626:	85 c0                	test   %eax,%eax
  800628:	79 14                	jns    80063e <fork+0x191>
		    	panic("sys page map fault %e");
  80062a:	83 ec 04             	sub    $0x4,%esp
  80062d:	68 97 22 80 00       	push   $0x802297
  800632:	6a 64                	push   $0x64
  800634:	68 65 22 80 00       	push   $0x802265
  800639:	e8 b2 0d 00 00       	call   8013f0 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80063e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800644:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80064a:	0f 85 de fe ff ff    	jne    80052e <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800650:	a1 04 40 80 00       	mov    0x804004,%eax
  800655:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	50                   	push   %eax
  80065f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800662:	57                   	push   %edi
  800663:	e8 69 fc ff ff       	call   8002d1 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800668:	83 c4 08             	add    $0x8,%esp
  80066b:	6a 02                	push   $0x2
  80066d:	57                   	push   %edi
  80066e:	e8 da fb ff ff       	call   80024d <sys_env_set_status>
	
	return envid;
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <sfork>:

envid_t
sfork(void)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800683:	b8 00 00 00 00       	mov    $0x0,%eax
  800688:	5d                   	pop    %ebp
  800689:	c3                   	ret    

0080068a <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	56                   	push   %esi
  80068e:	53                   	push   %ebx
  80068f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800692:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	68 b0 22 80 00       	push   $0x8022b0
  8006a1:	e8 23 0e 00 00       	call   8014c9 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006a6:	c7 04 24 90 00 80 00 	movl   $0x800090,(%esp)
  8006ad:	e8 c5 fc ff ff       	call   800377 <sys_thread_create>
  8006b2:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006b4:	83 c4 08             	add    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	68 b0 22 80 00       	push   $0x8022b0
  8006bd:	e8 07 0e 00 00       	call   8014c9 <cprintf>
	return id;
}
  8006c2:	89 f0                	mov    %esi,%eax
  8006c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006c7:	5b                   	pop    %ebx
  8006c8:	5e                   	pop    %esi
  8006c9:	5d                   	pop    %ebp
  8006ca:	c3                   	ret    

008006cb <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8006d1:	ff 75 08             	pushl  0x8(%ebp)
  8006d4:	e8 be fc ff ff       	call   800397 <sys_thread_free>
}
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	c9                   	leave  
  8006dd:	c3                   	ret    

008006de <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8006e4:	ff 75 08             	pushl  0x8(%ebp)
  8006e7:	e8 cb fc ff ff       	call   8003b7 <sys_thread_join>
}
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	c9                   	leave  
  8006f0:	c3                   	ret    

008006f1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	05 00 00 00 30       	add    $0x30000000,%eax
  8006fc:	c1 e8 0c             	shr    $0xc,%eax
}
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	05 00 00 00 30       	add    $0x30000000,%eax
  80070c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800711:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800723:	89 c2                	mov    %eax,%edx
  800725:	c1 ea 16             	shr    $0x16,%edx
  800728:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80072f:	f6 c2 01             	test   $0x1,%dl
  800732:	74 11                	je     800745 <fd_alloc+0x2d>
  800734:	89 c2                	mov    %eax,%edx
  800736:	c1 ea 0c             	shr    $0xc,%edx
  800739:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800740:	f6 c2 01             	test   $0x1,%dl
  800743:	75 09                	jne    80074e <fd_alloc+0x36>
			*fd_store = fd;
  800745:	89 01                	mov    %eax,(%ecx)
			return 0;
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	eb 17                	jmp    800765 <fd_alloc+0x4d>
  80074e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800753:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800758:	75 c9                	jne    800723 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80075a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800760:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80076d:	83 f8 1f             	cmp    $0x1f,%eax
  800770:	77 36                	ja     8007a8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800772:	c1 e0 0c             	shl    $0xc,%eax
  800775:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80077a:	89 c2                	mov    %eax,%edx
  80077c:	c1 ea 16             	shr    $0x16,%edx
  80077f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800786:	f6 c2 01             	test   $0x1,%dl
  800789:	74 24                	je     8007af <fd_lookup+0x48>
  80078b:	89 c2                	mov    %eax,%edx
  80078d:	c1 ea 0c             	shr    $0xc,%edx
  800790:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800797:	f6 c2 01             	test   $0x1,%dl
  80079a:	74 1a                	je     8007b6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079f:	89 02                	mov    %eax,(%edx)
	return 0;
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a6:	eb 13                	jmp    8007bb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ad:	eb 0c                	jmp    8007bb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b4:	eb 05                	jmp    8007bb <fd_lookup+0x54>
  8007b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c6:	ba 50 23 80 00       	mov    $0x802350,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8007cb:	eb 13                	jmp    8007e0 <dev_lookup+0x23>
  8007cd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8007d0:	39 08                	cmp    %ecx,(%eax)
  8007d2:	75 0c                	jne    8007e0 <dev_lookup+0x23>
			*dev = devtab[i];
  8007d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007de:	eb 31                	jmp    800811 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007e0:	8b 02                	mov    (%edx),%eax
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	75 e7                	jne    8007cd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8007eb:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8007f1:	83 ec 04             	sub    $0x4,%esp
  8007f4:	51                   	push   %ecx
  8007f5:	50                   	push   %eax
  8007f6:	68 d4 22 80 00       	push   $0x8022d4
  8007fb:	e8 c9 0c 00 00       	call   8014c9 <cprintf>
	*dev = 0;
  800800:	8b 45 0c             	mov    0xc(%ebp),%eax
  800803:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800809:	83 c4 10             	add    $0x10,%esp
  80080c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	56                   	push   %esi
  800817:	53                   	push   %ebx
  800818:	83 ec 10             	sub    $0x10,%esp
  80081b:	8b 75 08             	mov    0x8(%ebp),%esi
  80081e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800824:	50                   	push   %eax
  800825:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80082b:	c1 e8 0c             	shr    $0xc,%eax
  80082e:	50                   	push   %eax
  80082f:	e8 33 ff ff ff       	call   800767 <fd_lookup>
  800834:	83 c4 08             	add    $0x8,%esp
  800837:	85 c0                	test   %eax,%eax
  800839:	78 05                	js     800840 <fd_close+0x2d>
	    || fd != fd2)
  80083b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80083e:	74 0c                	je     80084c <fd_close+0x39>
		return (must_exist ? r : 0);
  800840:	84 db                	test   %bl,%bl
  800842:	ba 00 00 00 00       	mov    $0x0,%edx
  800847:	0f 44 c2             	cmove  %edx,%eax
  80084a:	eb 41                	jmp    80088d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80084c:	83 ec 08             	sub    $0x8,%esp
  80084f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800852:	50                   	push   %eax
  800853:	ff 36                	pushl  (%esi)
  800855:	e8 63 ff ff ff       	call   8007bd <dev_lookup>
  80085a:	89 c3                	mov    %eax,%ebx
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	85 c0                	test   %eax,%eax
  800861:	78 1a                	js     80087d <fd_close+0x6a>
		if (dev->dev_close)
  800863:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800866:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800869:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80086e:	85 c0                	test   %eax,%eax
  800870:	74 0b                	je     80087d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800872:	83 ec 0c             	sub    $0xc,%esp
  800875:	56                   	push   %esi
  800876:	ff d0                	call   *%eax
  800878:	89 c3                	mov    %eax,%ebx
  80087a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80087d:	83 ec 08             	sub    $0x8,%esp
  800880:	56                   	push   %esi
  800881:	6a 00                	push   $0x0
  800883:	e8 83 f9 ff ff       	call   80020b <sys_page_unmap>
	return r;
  800888:	83 c4 10             	add    $0x10,%esp
  80088b:	89 d8                	mov    %ebx,%eax
}
  80088d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800890:	5b                   	pop    %ebx
  800891:	5e                   	pop    %esi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80089a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089d:	50                   	push   %eax
  80089e:	ff 75 08             	pushl  0x8(%ebp)
  8008a1:	e8 c1 fe ff ff       	call   800767 <fd_lookup>
  8008a6:	83 c4 08             	add    $0x8,%esp
  8008a9:	85 c0                	test   %eax,%eax
  8008ab:	78 10                	js     8008bd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8008ad:	83 ec 08             	sub    $0x8,%esp
  8008b0:	6a 01                	push   $0x1
  8008b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8008b5:	e8 59 ff ff ff       	call   800813 <fd_close>
  8008ba:	83 c4 10             	add    $0x10,%esp
}
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    

008008bf <close_all>:

void
close_all(void)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	53                   	push   %ebx
  8008c3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8008c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8008cb:	83 ec 0c             	sub    $0xc,%esp
  8008ce:	53                   	push   %ebx
  8008cf:	e8 c0 ff ff ff       	call   800894 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8008d4:	83 c3 01             	add    $0x1,%ebx
  8008d7:	83 c4 10             	add    $0x10,%esp
  8008da:	83 fb 20             	cmp    $0x20,%ebx
  8008dd:	75 ec                	jne    8008cb <close_all+0xc>
		close(i);
}
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	57                   	push   %edi
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	83 ec 2c             	sub    $0x2c,%esp
  8008ed:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008f3:	50                   	push   %eax
  8008f4:	ff 75 08             	pushl  0x8(%ebp)
  8008f7:	e8 6b fe ff ff       	call   800767 <fd_lookup>
  8008fc:	83 c4 08             	add    $0x8,%esp
  8008ff:	85 c0                	test   %eax,%eax
  800901:	0f 88 c1 00 00 00    	js     8009c8 <dup+0xe4>
		return r;
	close(newfdnum);
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	56                   	push   %esi
  80090b:	e8 84 ff ff ff       	call   800894 <close>

	newfd = INDEX2FD(newfdnum);
  800910:	89 f3                	mov    %esi,%ebx
  800912:	c1 e3 0c             	shl    $0xc,%ebx
  800915:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80091b:	83 c4 04             	add    $0x4,%esp
  80091e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800921:	e8 db fd ff ff       	call   800701 <fd2data>
  800926:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800928:	89 1c 24             	mov    %ebx,(%esp)
  80092b:	e8 d1 fd ff ff       	call   800701 <fd2data>
  800930:	83 c4 10             	add    $0x10,%esp
  800933:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800936:	89 f8                	mov    %edi,%eax
  800938:	c1 e8 16             	shr    $0x16,%eax
  80093b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800942:	a8 01                	test   $0x1,%al
  800944:	74 37                	je     80097d <dup+0x99>
  800946:	89 f8                	mov    %edi,%eax
  800948:	c1 e8 0c             	shr    $0xc,%eax
  80094b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800952:	f6 c2 01             	test   $0x1,%dl
  800955:	74 26                	je     80097d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800957:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80095e:	83 ec 0c             	sub    $0xc,%esp
  800961:	25 07 0e 00 00       	and    $0xe07,%eax
  800966:	50                   	push   %eax
  800967:	ff 75 d4             	pushl  -0x2c(%ebp)
  80096a:	6a 00                	push   $0x0
  80096c:	57                   	push   %edi
  80096d:	6a 00                	push   $0x0
  80096f:	e8 55 f8 ff ff       	call   8001c9 <sys_page_map>
  800974:	89 c7                	mov    %eax,%edi
  800976:	83 c4 20             	add    $0x20,%esp
  800979:	85 c0                	test   %eax,%eax
  80097b:	78 2e                	js     8009ab <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80097d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800980:	89 d0                	mov    %edx,%eax
  800982:	c1 e8 0c             	shr    $0xc,%eax
  800985:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80098c:	83 ec 0c             	sub    $0xc,%esp
  80098f:	25 07 0e 00 00       	and    $0xe07,%eax
  800994:	50                   	push   %eax
  800995:	53                   	push   %ebx
  800996:	6a 00                	push   $0x0
  800998:	52                   	push   %edx
  800999:	6a 00                	push   $0x0
  80099b:	e8 29 f8 ff ff       	call   8001c9 <sys_page_map>
  8009a0:	89 c7                	mov    %eax,%edi
  8009a2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8009a5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009a7:	85 ff                	test   %edi,%edi
  8009a9:	79 1d                	jns    8009c8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8009ab:	83 ec 08             	sub    $0x8,%esp
  8009ae:	53                   	push   %ebx
  8009af:	6a 00                	push   $0x0
  8009b1:	e8 55 f8 ff ff       	call   80020b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8009b6:	83 c4 08             	add    $0x8,%esp
  8009b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009bc:	6a 00                	push   $0x0
  8009be:	e8 48 f8 ff ff       	call   80020b <sys_page_unmap>
	return r;
  8009c3:	83 c4 10             	add    $0x10,%esp
  8009c6:	89 f8                	mov    %edi,%eax
}
  8009c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009cb:	5b                   	pop    %ebx
  8009cc:	5e                   	pop    %esi
  8009cd:	5f                   	pop    %edi
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	53                   	push   %ebx
  8009d4:	83 ec 14             	sub    $0x14,%esp
  8009d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009dd:	50                   	push   %eax
  8009de:	53                   	push   %ebx
  8009df:	e8 83 fd ff ff       	call   800767 <fd_lookup>
  8009e4:	83 c4 08             	add    $0x8,%esp
  8009e7:	89 c2                	mov    %eax,%edx
  8009e9:	85 c0                	test   %eax,%eax
  8009eb:	78 70                	js     800a5d <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009ed:	83 ec 08             	sub    $0x8,%esp
  8009f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009f3:	50                   	push   %eax
  8009f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009f7:	ff 30                	pushl  (%eax)
  8009f9:	e8 bf fd ff ff       	call   8007bd <dev_lookup>
  8009fe:	83 c4 10             	add    $0x10,%esp
  800a01:	85 c0                	test   %eax,%eax
  800a03:	78 4f                	js     800a54 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a05:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a08:	8b 42 08             	mov    0x8(%edx),%eax
  800a0b:	83 e0 03             	and    $0x3,%eax
  800a0e:	83 f8 01             	cmp    $0x1,%eax
  800a11:	75 24                	jne    800a37 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a13:	a1 04 40 80 00       	mov    0x804004,%eax
  800a18:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a1e:	83 ec 04             	sub    $0x4,%esp
  800a21:	53                   	push   %ebx
  800a22:	50                   	push   %eax
  800a23:	68 15 23 80 00       	push   $0x802315
  800a28:	e8 9c 0a 00 00       	call   8014c9 <cprintf>
		return -E_INVAL;
  800a2d:	83 c4 10             	add    $0x10,%esp
  800a30:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800a35:	eb 26                	jmp    800a5d <read+0x8d>
	}
	if (!dev->dev_read)
  800a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a3a:	8b 40 08             	mov    0x8(%eax),%eax
  800a3d:	85 c0                	test   %eax,%eax
  800a3f:	74 17                	je     800a58 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800a41:	83 ec 04             	sub    $0x4,%esp
  800a44:	ff 75 10             	pushl  0x10(%ebp)
  800a47:	ff 75 0c             	pushl  0xc(%ebp)
  800a4a:	52                   	push   %edx
  800a4b:	ff d0                	call   *%eax
  800a4d:	89 c2                	mov    %eax,%edx
  800a4f:	83 c4 10             	add    $0x10,%esp
  800a52:	eb 09                	jmp    800a5d <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a54:	89 c2                	mov    %eax,%edx
  800a56:	eb 05                	jmp    800a5d <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a58:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a5d:	89 d0                	mov    %edx,%eax
  800a5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a62:	c9                   	leave  
  800a63:	c3                   	ret    

00800a64 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	83 ec 0c             	sub    $0xc,%esp
  800a6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a70:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a78:	eb 21                	jmp    800a9b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a7a:	83 ec 04             	sub    $0x4,%esp
  800a7d:	89 f0                	mov    %esi,%eax
  800a7f:	29 d8                	sub    %ebx,%eax
  800a81:	50                   	push   %eax
  800a82:	89 d8                	mov    %ebx,%eax
  800a84:	03 45 0c             	add    0xc(%ebp),%eax
  800a87:	50                   	push   %eax
  800a88:	57                   	push   %edi
  800a89:	e8 42 ff ff ff       	call   8009d0 <read>
		if (m < 0)
  800a8e:	83 c4 10             	add    $0x10,%esp
  800a91:	85 c0                	test   %eax,%eax
  800a93:	78 10                	js     800aa5 <readn+0x41>
			return m;
		if (m == 0)
  800a95:	85 c0                	test   %eax,%eax
  800a97:	74 0a                	je     800aa3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a99:	01 c3                	add    %eax,%ebx
  800a9b:	39 f3                	cmp    %esi,%ebx
  800a9d:	72 db                	jb     800a7a <readn+0x16>
  800a9f:	89 d8                	mov    %ebx,%eax
  800aa1:	eb 02                	jmp    800aa5 <readn+0x41>
  800aa3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800aa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	53                   	push   %ebx
  800ab1:	83 ec 14             	sub    $0x14,%esp
  800ab4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ab7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800aba:	50                   	push   %eax
  800abb:	53                   	push   %ebx
  800abc:	e8 a6 fc ff ff       	call   800767 <fd_lookup>
  800ac1:	83 c4 08             	add    $0x8,%esp
  800ac4:	89 c2                	mov    %eax,%edx
  800ac6:	85 c0                	test   %eax,%eax
  800ac8:	78 6b                	js     800b35 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800aca:	83 ec 08             	sub    $0x8,%esp
  800acd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad0:	50                   	push   %eax
  800ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ad4:	ff 30                	pushl  (%eax)
  800ad6:	e8 e2 fc ff ff       	call   8007bd <dev_lookup>
  800adb:	83 c4 10             	add    $0x10,%esp
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	78 4a                	js     800b2c <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ae5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ae9:	75 24                	jne    800b0f <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800aeb:	a1 04 40 80 00       	mov    0x804004,%eax
  800af0:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800af6:	83 ec 04             	sub    $0x4,%esp
  800af9:	53                   	push   %ebx
  800afa:	50                   	push   %eax
  800afb:	68 31 23 80 00       	push   $0x802331
  800b00:	e8 c4 09 00 00       	call   8014c9 <cprintf>
		return -E_INVAL;
  800b05:	83 c4 10             	add    $0x10,%esp
  800b08:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b0d:	eb 26                	jmp    800b35 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b12:	8b 52 0c             	mov    0xc(%edx),%edx
  800b15:	85 d2                	test   %edx,%edx
  800b17:	74 17                	je     800b30 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b19:	83 ec 04             	sub    $0x4,%esp
  800b1c:	ff 75 10             	pushl  0x10(%ebp)
  800b1f:	ff 75 0c             	pushl  0xc(%ebp)
  800b22:	50                   	push   %eax
  800b23:	ff d2                	call   *%edx
  800b25:	89 c2                	mov    %eax,%edx
  800b27:	83 c4 10             	add    $0x10,%esp
  800b2a:	eb 09                	jmp    800b35 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b2c:	89 c2                	mov    %eax,%edx
  800b2e:	eb 05                	jmp    800b35 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800b30:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800b35:	89 d0                	mov    %edx,%eax
  800b37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3a:	c9                   	leave  
  800b3b:	c3                   	ret    

00800b3c <seek>:

int
seek(int fdnum, off_t offset)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b42:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b45:	50                   	push   %eax
  800b46:	ff 75 08             	pushl  0x8(%ebp)
  800b49:	e8 19 fc ff ff       	call   800767 <fd_lookup>
  800b4e:	83 c4 08             	add    $0x8,%esp
  800b51:	85 c0                	test   %eax,%eax
  800b53:	78 0e                	js     800b63 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b55:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    

00800b65 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	53                   	push   %ebx
  800b69:	83 ec 14             	sub    $0x14,%esp
  800b6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b72:	50                   	push   %eax
  800b73:	53                   	push   %ebx
  800b74:	e8 ee fb ff ff       	call   800767 <fd_lookup>
  800b79:	83 c4 08             	add    $0x8,%esp
  800b7c:	89 c2                	mov    %eax,%edx
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	78 68                	js     800bea <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b82:	83 ec 08             	sub    $0x8,%esp
  800b85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b88:	50                   	push   %eax
  800b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b8c:	ff 30                	pushl  (%eax)
  800b8e:	e8 2a fc ff ff       	call   8007bd <dev_lookup>
  800b93:	83 c4 10             	add    $0x10,%esp
  800b96:	85 c0                	test   %eax,%eax
  800b98:	78 47                	js     800be1 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b9d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ba1:	75 24                	jne    800bc7 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800ba3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800ba8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800bae:	83 ec 04             	sub    $0x4,%esp
  800bb1:	53                   	push   %ebx
  800bb2:	50                   	push   %eax
  800bb3:	68 f4 22 80 00       	push   $0x8022f4
  800bb8:	e8 0c 09 00 00       	call   8014c9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800bbd:	83 c4 10             	add    $0x10,%esp
  800bc0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800bc5:	eb 23                	jmp    800bea <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800bc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bca:	8b 52 18             	mov    0x18(%edx),%edx
  800bcd:	85 d2                	test   %edx,%edx
  800bcf:	74 14                	je     800be5 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800bd1:	83 ec 08             	sub    $0x8,%esp
  800bd4:	ff 75 0c             	pushl  0xc(%ebp)
  800bd7:	50                   	push   %eax
  800bd8:	ff d2                	call   *%edx
  800bda:	89 c2                	mov    %eax,%edx
  800bdc:	83 c4 10             	add    $0x10,%esp
  800bdf:	eb 09                	jmp    800bea <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800be1:	89 c2                	mov    %eax,%edx
  800be3:	eb 05                	jmp    800bea <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800be5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800bea:	89 d0                	mov    %edx,%eax
  800bec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bef:	c9                   	leave  
  800bf0:	c3                   	ret    

00800bf1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 14             	sub    $0x14,%esp
  800bf8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bfb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bfe:	50                   	push   %eax
  800bff:	ff 75 08             	pushl  0x8(%ebp)
  800c02:	e8 60 fb ff ff       	call   800767 <fd_lookup>
  800c07:	83 c4 08             	add    $0x8,%esp
  800c0a:	89 c2                	mov    %eax,%edx
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	78 58                	js     800c68 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c10:	83 ec 08             	sub    $0x8,%esp
  800c13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c16:	50                   	push   %eax
  800c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c1a:	ff 30                	pushl  (%eax)
  800c1c:	e8 9c fb ff ff       	call   8007bd <dev_lookup>
  800c21:	83 c4 10             	add    $0x10,%esp
  800c24:	85 c0                	test   %eax,%eax
  800c26:	78 37                	js     800c5f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c2f:	74 32                	je     800c63 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c31:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c34:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c3b:	00 00 00 
	stat->st_isdir = 0;
  800c3e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c45:	00 00 00 
	stat->st_dev = dev;
  800c48:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c4e:	83 ec 08             	sub    $0x8,%esp
  800c51:	53                   	push   %ebx
  800c52:	ff 75 f0             	pushl  -0x10(%ebp)
  800c55:	ff 50 14             	call   *0x14(%eax)
  800c58:	89 c2                	mov    %eax,%edx
  800c5a:	83 c4 10             	add    $0x10,%esp
  800c5d:	eb 09                	jmp    800c68 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c5f:	89 c2                	mov    %eax,%edx
  800c61:	eb 05                	jmp    800c68 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c63:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c68:	89 d0                	mov    %edx,%eax
  800c6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c6d:	c9                   	leave  
  800c6e:	c3                   	ret    

00800c6f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c74:	83 ec 08             	sub    $0x8,%esp
  800c77:	6a 00                	push   $0x0
  800c79:	ff 75 08             	pushl  0x8(%ebp)
  800c7c:	e8 e3 01 00 00       	call   800e64 <open>
  800c81:	89 c3                	mov    %eax,%ebx
  800c83:	83 c4 10             	add    $0x10,%esp
  800c86:	85 c0                	test   %eax,%eax
  800c88:	78 1b                	js     800ca5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c8a:	83 ec 08             	sub    $0x8,%esp
  800c8d:	ff 75 0c             	pushl  0xc(%ebp)
  800c90:	50                   	push   %eax
  800c91:	e8 5b ff ff ff       	call   800bf1 <fstat>
  800c96:	89 c6                	mov    %eax,%esi
	close(fd);
  800c98:	89 1c 24             	mov    %ebx,(%esp)
  800c9b:	e8 f4 fb ff ff       	call   800894 <close>
	return r;
  800ca0:	83 c4 10             	add    $0x10,%esp
  800ca3:	89 f0                	mov    %esi,%eax
}
  800ca5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	89 c6                	mov    %eax,%esi
  800cb3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800cb5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800cbc:	75 12                	jne    800cd0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800cbe:	83 ec 0c             	sub    $0xc,%esp
  800cc1:	6a 01                	push   $0x1
  800cc3:	e8 39 12 00 00       	call   801f01 <ipc_find_env>
  800cc8:	a3 00 40 80 00       	mov    %eax,0x804000
  800ccd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800cd0:	6a 07                	push   $0x7
  800cd2:	68 00 50 80 00       	push   $0x805000
  800cd7:	56                   	push   %esi
  800cd8:	ff 35 00 40 80 00    	pushl  0x804000
  800cde:	e8 bc 11 00 00       	call   801e9f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ce3:	83 c4 0c             	add    $0xc,%esp
  800ce6:	6a 00                	push   $0x0
  800ce8:	53                   	push   %ebx
  800ce9:	6a 00                	push   $0x0
  800ceb:	e8 34 11 00 00       	call   801e24 <ipc_recv>
}
  800cf0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800d00:	8b 40 0c             	mov    0xc(%eax),%eax
  800d03:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d10:	ba 00 00 00 00       	mov    $0x0,%edx
  800d15:	b8 02 00 00 00       	mov    $0x2,%eax
  800d1a:	e8 8d ff ff ff       	call   800cac <fsipc>
}
  800d1f:	c9                   	leave  
  800d20:	c3                   	ret    

00800d21 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	8b 40 0c             	mov    0xc(%eax),%eax
  800d2d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d32:	ba 00 00 00 00       	mov    $0x0,%edx
  800d37:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3c:	e8 6b ff ff ff       	call   800cac <fsipc>
}
  800d41:	c9                   	leave  
  800d42:	c3                   	ret    

00800d43 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	53                   	push   %ebx
  800d47:	83 ec 04             	sub    $0x4,%esp
  800d4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	8b 40 0c             	mov    0xc(%eax),%eax
  800d53:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d58:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d62:	e8 45 ff ff ff       	call   800cac <fsipc>
  800d67:	85 c0                	test   %eax,%eax
  800d69:	78 2c                	js     800d97 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d6b:	83 ec 08             	sub    $0x8,%esp
  800d6e:	68 00 50 80 00       	push   $0x805000
  800d73:	53                   	push   %ebx
  800d74:	e8 d5 0c 00 00       	call   801a4e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d79:	a1 80 50 80 00       	mov    0x805080,%eax
  800d7e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d84:	a1 84 50 80 00       	mov    0x805084,%eax
  800d89:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d8f:	83 c4 10             	add    $0x10,%esp
  800d92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d9a:	c9                   	leave  
  800d9b:	c3                   	ret    

00800d9c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	83 ec 0c             	sub    $0xc,%esp
  800da2:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800da5:	8b 55 08             	mov    0x8(%ebp),%edx
  800da8:	8b 52 0c             	mov    0xc(%edx),%edx
  800dab:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800db1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800db6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800dbb:	0f 47 c2             	cmova  %edx,%eax
  800dbe:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800dc3:	50                   	push   %eax
  800dc4:	ff 75 0c             	pushl  0xc(%ebp)
  800dc7:	68 08 50 80 00       	push   $0x805008
  800dcc:	e8 0f 0e 00 00       	call   801be0 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800dd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd6:	b8 04 00 00 00       	mov    $0x4,%eax
  800ddb:	e8 cc fe ff ff       	call   800cac <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800de0:	c9                   	leave  
  800de1:	c3                   	ret    

00800de2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
  800de7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800dea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ded:	8b 40 0c             	mov    0xc(%eax),%eax
  800df0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800df5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800dfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800e00:	b8 03 00 00 00       	mov    $0x3,%eax
  800e05:	e8 a2 fe ff ff       	call   800cac <fsipc>
  800e0a:	89 c3                	mov    %eax,%ebx
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	78 4b                	js     800e5b <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e10:	39 c6                	cmp    %eax,%esi
  800e12:	73 16                	jae    800e2a <devfile_read+0x48>
  800e14:	68 60 23 80 00       	push   $0x802360
  800e19:	68 67 23 80 00       	push   $0x802367
  800e1e:	6a 7c                	push   $0x7c
  800e20:	68 7c 23 80 00       	push   $0x80237c
  800e25:	e8 c6 05 00 00       	call   8013f0 <_panic>
	assert(r <= PGSIZE);
  800e2a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e2f:	7e 16                	jle    800e47 <devfile_read+0x65>
  800e31:	68 87 23 80 00       	push   $0x802387
  800e36:	68 67 23 80 00       	push   $0x802367
  800e3b:	6a 7d                	push   $0x7d
  800e3d:	68 7c 23 80 00       	push   $0x80237c
  800e42:	e8 a9 05 00 00       	call   8013f0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e47:	83 ec 04             	sub    $0x4,%esp
  800e4a:	50                   	push   %eax
  800e4b:	68 00 50 80 00       	push   $0x805000
  800e50:	ff 75 0c             	pushl  0xc(%ebp)
  800e53:	e8 88 0d 00 00       	call   801be0 <memmove>
	return r;
  800e58:	83 c4 10             	add    $0x10,%esp
}
  800e5b:	89 d8                	mov    %ebx,%eax
  800e5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    

00800e64 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	53                   	push   %ebx
  800e68:	83 ec 20             	sub    $0x20,%esp
  800e6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e6e:	53                   	push   %ebx
  800e6f:	e8 a1 0b 00 00       	call   801a15 <strlen>
  800e74:	83 c4 10             	add    $0x10,%esp
  800e77:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e7c:	7f 67                	jg     800ee5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e7e:	83 ec 0c             	sub    $0xc,%esp
  800e81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e84:	50                   	push   %eax
  800e85:	e8 8e f8 ff ff       	call   800718 <fd_alloc>
  800e8a:	83 c4 10             	add    $0x10,%esp
		return r;
  800e8d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	78 57                	js     800eea <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e93:	83 ec 08             	sub    $0x8,%esp
  800e96:	53                   	push   %ebx
  800e97:	68 00 50 80 00       	push   $0x805000
  800e9c:	e8 ad 0b 00 00       	call   801a4e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea4:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ea9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800eac:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb1:	e8 f6 fd ff ff       	call   800cac <fsipc>
  800eb6:	89 c3                	mov    %eax,%ebx
  800eb8:	83 c4 10             	add    $0x10,%esp
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	79 14                	jns    800ed3 <open+0x6f>
		fd_close(fd, 0);
  800ebf:	83 ec 08             	sub    $0x8,%esp
  800ec2:	6a 00                	push   $0x0
  800ec4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec7:	e8 47 f9 ff ff       	call   800813 <fd_close>
		return r;
  800ecc:	83 c4 10             	add    $0x10,%esp
  800ecf:	89 da                	mov    %ebx,%edx
  800ed1:	eb 17                	jmp    800eea <open+0x86>
	}

	return fd2num(fd);
  800ed3:	83 ec 0c             	sub    $0xc,%esp
  800ed6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed9:	e8 13 f8 ff ff       	call   8006f1 <fd2num>
  800ede:	89 c2                	mov    %eax,%edx
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	eb 05                	jmp    800eea <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ee5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800eea:	89 d0                	mov    %edx,%eax
  800eec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eef:	c9                   	leave  
  800ef0:	c3                   	ret    

00800ef1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ef7:	ba 00 00 00 00       	mov    $0x0,%edx
  800efc:	b8 08 00 00 00       	mov    $0x8,%eax
  800f01:	e8 a6 fd ff ff       	call   800cac <fsipc>
}
  800f06:	c9                   	leave  
  800f07:	c3                   	ret    

00800f08 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
  800f0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	ff 75 08             	pushl  0x8(%ebp)
  800f16:	e8 e6 f7 ff ff       	call   800701 <fd2data>
  800f1b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f1d:	83 c4 08             	add    $0x8,%esp
  800f20:	68 93 23 80 00       	push   $0x802393
  800f25:	53                   	push   %ebx
  800f26:	e8 23 0b 00 00       	call   801a4e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f2b:	8b 46 04             	mov    0x4(%esi),%eax
  800f2e:	2b 06                	sub    (%esi),%eax
  800f30:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f36:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f3d:	00 00 00 
	stat->st_dev = &devpipe;
  800f40:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f47:	30 80 00 
	return 0;
}
  800f4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f52:	5b                   	pop    %ebx
  800f53:	5e                   	pop    %esi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	53                   	push   %ebx
  800f5a:	83 ec 0c             	sub    $0xc,%esp
  800f5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f60:	53                   	push   %ebx
  800f61:	6a 00                	push   $0x0
  800f63:	e8 a3 f2 ff ff       	call   80020b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f68:	89 1c 24             	mov    %ebx,(%esp)
  800f6b:	e8 91 f7 ff ff       	call   800701 <fd2data>
  800f70:	83 c4 08             	add    $0x8,%esp
  800f73:	50                   	push   %eax
  800f74:	6a 00                	push   $0x0
  800f76:	e8 90 f2 ff ff       	call   80020b <sys_page_unmap>
}
  800f7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f7e:	c9                   	leave  
  800f7f:	c3                   	ret    

00800f80 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	57                   	push   %edi
  800f84:	56                   	push   %esi
  800f85:	53                   	push   %ebx
  800f86:	83 ec 1c             	sub    $0x1c,%esp
  800f89:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f8c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f8e:	a1 04 40 80 00       	mov    0x804004,%eax
  800f93:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	ff 75 e0             	pushl  -0x20(%ebp)
  800f9f:	e8 a2 0f 00 00       	call   801f46 <pageref>
  800fa4:	89 c3                	mov    %eax,%ebx
  800fa6:	89 3c 24             	mov    %edi,(%esp)
  800fa9:	e8 98 0f 00 00       	call   801f46 <pageref>
  800fae:	83 c4 10             	add    $0x10,%esp
  800fb1:	39 c3                	cmp    %eax,%ebx
  800fb3:	0f 94 c1             	sete   %cl
  800fb6:	0f b6 c9             	movzbl %cl,%ecx
  800fb9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800fbc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fc2:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  800fc8:	39 ce                	cmp    %ecx,%esi
  800fca:	74 1e                	je     800fea <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800fcc:	39 c3                	cmp    %eax,%ebx
  800fce:	75 be                	jne    800f8e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800fd0:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  800fd6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd9:	50                   	push   %eax
  800fda:	56                   	push   %esi
  800fdb:	68 9a 23 80 00       	push   $0x80239a
  800fe0:	e8 e4 04 00 00       	call   8014c9 <cprintf>
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	eb a4                	jmp    800f8e <_pipeisclosed+0xe>
	}
}
  800fea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	57                   	push   %edi
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 28             	sub    $0x28,%esp
  800ffe:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801001:	56                   	push   %esi
  801002:	e8 fa f6 ff ff       	call   800701 <fd2data>
  801007:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	bf 00 00 00 00       	mov    $0x0,%edi
  801011:	eb 4b                	jmp    80105e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801013:	89 da                	mov    %ebx,%edx
  801015:	89 f0                	mov    %esi,%eax
  801017:	e8 64 ff ff ff       	call   800f80 <_pipeisclosed>
  80101c:	85 c0                	test   %eax,%eax
  80101e:	75 48                	jne    801068 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801020:	e8 42 f1 ff ff       	call   800167 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801025:	8b 43 04             	mov    0x4(%ebx),%eax
  801028:	8b 0b                	mov    (%ebx),%ecx
  80102a:	8d 51 20             	lea    0x20(%ecx),%edx
  80102d:	39 d0                	cmp    %edx,%eax
  80102f:	73 e2                	jae    801013 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801031:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801034:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801038:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80103b:	89 c2                	mov    %eax,%edx
  80103d:	c1 fa 1f             	sar    $0x1f,%edx
  801040:	89 d1                	mov    %edx,%ecx
  801042:	c1 e9 1b             	shr    $0x1b,%ecx
  801045:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801048:	83 e2 1f             	and    $0x1f,%edx
  80104b:	29 ca                	sub    %ecx,%edx
  80104d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801051:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801055:	83 c0 01             	add    $0x1,%eax
  801058:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80105b:	83 c7 01             	add    $0x1,%edi
  80105e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801061:	75 c2                	jne    801025 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801063:	8b 45 10             	mov    0x10(%ebp),%eax
  801066:	eb 05                	jmp    80106d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801068:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80106d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5f                   	pop    %edi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    

00801075 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	57                   	push   %edi
  801079:	56                   	push   %esi
  80107a:	53                   	push   %ebx
  80107b:	83 ec 18             	sub    $0x18,%esp
  80107e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801081:	57                   	push   %edi
  801082:	e8 7a f6 ff ff       	call   800701 <fd2data>
  801087:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801089:	83 c4 10             	add    $0x10,%esp
  80108c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801091:	eb 3d                	jmp    8010d0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801093:	85 db                	test   %ebx,%ebx
  801095:	74 04                	je     80109b <devpipe_read+0x26>
				return i;
  801097:	89 d8                	mov    %ebx,%eax
  801099:	eb 44                	jmp    8010df <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80109b:	89 f2                	mov    %esi,%edx
  80109d:	89 f8                	mov    %edi,%eax
  80109f:	e8 dc fe ff ff       	call   800f80 <_pipeisclosed>
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	75 32                	jne    8010da <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8010a8:	e8 ba f0 ff ff       	call   800167 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8010ad:	8b 06                	mov    (%esi),%eax
  8010af:	3b 46 04             	cmp    0x4(%esi),%eax
  8010b2:	74 df                	je     801093 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010b4:	99                   	cltd   
  8010b5:	c1 ea 1b             	shr    $0x1b,%edx
  8010b8:	01 d0                	add    %edx,%eax
  8010ba:	83 e0 1f             	and    $0x1f,%eax
  8010bd:	29 d0                	sub    %edx,%eax
  8010bf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8010c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8010ca:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010cd:	83 c3 01             	add    $0x1,%ebx
  8010d0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010d3:	75 d8                	jne    8010ad <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8010d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d8:	eb 05                	jmp    8010df <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010da:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8010df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e2:	5b                   	pop    %ebx
  8010e3:	5e                   	pop    %esi
  8010e4:	5f                   	pop    %edi
  8010e5:	5d                   	pop    %ebp
  8010e6:	c3                   	ret    

008010e7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	56                   	push   %esi
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8010ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f2:	50                   	push   %eax
  8010f3:	e8 20 f6 ff ff       	call   800718 <fd_alloc>
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	89 c2                	mov    %eax,%edx
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	0f 88 2c 01 00 00    	js     801231 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801105:	83 ec 04             	sub    $0x4,%esp
  801108:	68 07 04 00 00       	push   $0x407
  80110d:	ff 75 f4             	pushl  -0xc(%ebp)
  801110:	6a 00                	push   $0x0
  801112:	e8 6f f0 ff ff       	call   800186 <sys_page_alloc>
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	89 c2                	mov    %eax,%edx
  80111c:	85 c0                	test   %eax,%eax
  80111e:	0f 88 0d 01 00 00    	js     801231 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801124:	83 ec 0c             	sub    $0xc,%esp
  801127:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	e8 e8 f5 ff ff       	call   800718 <fd_alloc>
  801130:	89 c3                	mov    %eax,%ebx
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	85 c0                	test   %eax,%eax
  801137:	0f 88 e2 00 00 00    	js     80121f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80113d:	83 ec 04             	sub    $0x4,%esp
  801140:	68 07 04 00 00       	push   $0x407
  801145:	ff 75 f0             	pushl  -0x10(%ebp)
  801148:	6a 00                	push   $0x0
  80114a:	e8 37 f0 ff ff       	call   800186 <sys_page_alloc>
  80114f:	89 c3                	mov    %eax,%ebx
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	0f 88 c3 00 00 00    	js     80121f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80115c:	83 ec 0c             	sub    $0xc,%esp
  80115f:	ff 75 f4             	pushl  -0xc(%ebp)
  801162:	e8 9a f5 ff ff       	call   800701 <fd2data>
  801167:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801169:	83 c4 0c             	add    $0xc,%esp
  80116c:	68 07 04 00 00       	push   $0x407
  801171:	50                   	push   %eax
  801172:	6a 00                	push   $0x0
  801174:	e8 0d f0 ff ff       	call   800186 <sys_page_alloc>
  801179:	89 c3                	mov    %eax,%ebx
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	85 c0                	test   %eax,%eax
  801180:	0f 88 89 00 00 00    	js     80120f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801186:	83 ec 0c             	sub    $0xc,%esp
  801189:	ff 75 f0             	pushl  -0x10(%ebp)
  80118c:	e8 70 f5 ff ff       	call   800701 <fd2data>
  801191:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801198:	50                   	push   %eax
  801199:	6a 00                	push   $0x0
  80119b:	56                   	push   %esi
  80119c:	6a 00                	push   $0x0
  80119e:	e8 26 f0 ff ff       	call   8001c9 <sys_page_map>
  8011a3:	89 c3                	mov    %eax,%ebx
  8011a5:	83 c4 20             	add    $0x20,%esp
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	78 55                	js     801201 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8011ac:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8011b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8011c1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ca:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8011cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8011d6:	83 ec 0c             	sub    $0xc,%esp
  8011d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8011dc:	e8 10 f5 ff ff       	call   8006f1 <fd2num>
  8011e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8011e6:	83 c4 04             	add    $0x4,%esp
  8011e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8011ec:	e8 00 f5 ff ff       	call   8006f1 <fd2num>
  8011f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f4:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ff:	eb 30                	jmp    801231 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801201:	83 ec 08             	sub    $0x8,%esp
  801204:	56                   	push   %esi
  801205:	6a 00                	push   $0x0
  801207:	e8 ff ef ff ff       	call   80020b <sys_page_unmap>
  80120c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80120f:	83 ec 08             	sub    $0x8,%esp
  801212:	ff 75 f0             	pushl  -0x10(%ebp)
  801215:	6a 00                	push   $0x0
  801217:	e8 ef ef ff ff       	call   80020b <sys_page_unmap>
  80121c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80121f:	83 ec 08             	sub    $0x8,%esp
  801222:	ff 75 f4             	pushl  -0xc(%ebp)
  801225:	6a 00                	push   $0x0
  801227:	e8 df ef ff ff       	call   80020b <sys_page_unmap>
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801231:	89 d0                	mov    %edx,%eax
  801233:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801236:	5b                   	pop    %ebx
  801237:	5e                   	pop    %esi
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    

0080123a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801240:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801243:	50                   	push   %eax
  801244:	ff 75 08             	pushl  0x8(%ebp)
  801247:	e8 1b f5 ff ff       	call   800767 <fd_lookup>
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	85 c0                	test   %eax,%eax
  801251:	78 18                	js     80126b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801253:	83 ec 0c             	sub    $0xc,%esp
  801256:	ff 75 f4             	pushl  -0xc(%ebp)
  801259:	e8 a3 f4 ff ff       	call   800701 <fd2data>
	return _pipeisclosed(fd, p);
  80125e:	89 c2                	mov    %eax,%edx
  801260:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801263:	e8 18 fd ff ff       	call   800f80 <_pipeisclosed>
  801268:	83 c4 10             	add    $0x10,%esp
}
  80126b:	c9                   	leave  
  80126c:	c3                   	ret    

0080126d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80127d:	68 b2 23 80 00       	push   $0x8023b2
  801282:	ff 75 0c             	pushl  0xc(%ebp)
  801285:	e8 c4 07 00 00       	call   801a4e <strcpy>
	return 0;
}
  80128a:	b8 00 00 00 00       	mov    $0x0,%eax
  80128f:	c9                   	leave  
  801290:	c3                   	ret    

00801291 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	57                   	push   %edi
  801295:	56                   	push   %esi
  801296:	53                   	push   %ebx
  801297:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80129d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012a2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012a8:	eb 2d                	jmp    8012d7 <devcons_write+0x46>
		m = n - tot;
  8012aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012ad:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8012af:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8012b2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8012b7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012ba:	83 ec 04             	sub    $0x4,%esp
  8012bd:	53                   	push   %ebx
  8012be:	03 45 0c             	add    0xc(%ebp),%eax
  8012c1:	50                   	push   %eax
  8012c2:	57                   	push   %edi
  8012c3:	e8 18 09 00 00       	call   801be0 <memmove>
		sys_cputs(buf, m);
  8012c8:	83 c4 08             	add    $0x8,%esp
  8012cb:	53                   	push   %ebx
  8012cc:	57                   	push   %edi
  8012cd:	e8 f8 ed ff ff       	call   8000ca <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012d2:	01 de                	add    %ebx,%esi
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	89 f0                	mov    %esi,%eax
  8012d9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8012dc:	72 cc                	jb     8012aa <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8012de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e1:	5b                   	pop    %ebx
  8012e2:	5e                   	pop    %esi
  8012e3:	5f                   	pop    %edi
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    

008012e6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8012f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012f5:	74 2a                	je     801321 <devcons_read+0x3b>
  8012f7:	eb 05                	jmp    8012fe <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012f9:	e8 69 ee ff ff       	call   800167 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012fe:	e8 e5 ed ff ff       	call   8000e8 <sys_cgetc>
  801303:	85 c0                	test   %eax,%eax
  801305:	74 f2                	je     8012f9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801307:	85 c0                	test   %eax,%eax
  801309:	78 16                	js     801321 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80130b:	83 f8 04             	cmp    $0x4,%eax
  80130e:	74 0c                	je     80131c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801310:	8b 55 0c             	mov    0xc(%ebp),%edx
  801313:	88 02                	mov    %al,(%edx)
	return 1;
  801315:	b8 01 00 00 00       	mov    $0x1,%eax
  80131a:	eb 05                	jmp    801321 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80131c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801321:	c9                   	leave  
  801322:	c3                   	ret    

00801323 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801329:	8b 45 08             	mov    0x8(%ebp),%eax
  80132c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80132f:	6a 01                	push   $0x1
  801331:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801334:	50                   	push   %eax
  801335:	e8 90 ed ff ff       	call   8000ca <sys_cputs>
}
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <getchar>:

int
getchar(void)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801345:	6a 01                	push   $0x1
  801347:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80134a:	50                   	push   %eax
  80134b:	6a 00                	push   $0x0
  80134d:	e8 7e f6 ff ff       	call   8009d0 <read>
	if (r < 0)
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 0f                	js     801368 <getchar+0x29>
		return r;
	if (r < 1)
  801359:	85 c0                	test   %eax,%eax
  80135b:	7e 06                	jle    801363 <getchar+0x24>
		return -E_EOF;
	return c;
  80135d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801361:	eb 05                	jmp    801368 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801363:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801368:	c9                   	leave  
  801369:	c3                   	ret    

0080136a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801370:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801373:	50                   	push   %eax
  801374:	ff 75 08             	pushl  0x8(%ebp)
  801377:	e8 eb f3 ff ff       	call   800767 <fd_lookup>
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 11                	js     801394 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801386:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80138c:	39 10                	cmp    %edx,(%eax)
  80138e:	0f 94 c0             	sete   %al
  801391:	0f b6 c0             	movzbl %al,%eax
}
  801394:	c9                   	leave  
  801395:	c3                   	ret    

00801396 <opencons>:

int
opencons(void)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80139c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139f:	50                   	push   %eax
  8013a0:	e8 73 f3 ff ff       	call   800718 <fd_alloc>
  8013a5:	83 c4 10             	add    $0x10,%esp
		return r;
  8013a8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	78 3e                	js     8013ec <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013ae:	83 ec 04             	sub    $0x4,%esp
  8013b1:	68 07 04 00 00       	push   $0x407
  8013b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b9:	6a 00                	push   $0x0
  8013bb:	e8 c6 ed ff ff       	call   800186 <sys_page_alloc>
  8013c0:	83 c4 10             	add    $0x10,%esp
		return r;
  8013c3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 23                	js     8013ec <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8013c9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8013d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013de:	83 ec 0c             	sub    $0xc,%esp
  8013e1:	50                   	push   %eax
  8013e2:	e8 0a f3 ff ff       	call   8006f1 <fd2num>
  8013e7:	89 c2                	mov    %eax,%edx
  8013e9:	83 c4 10             	add    $0x10,%esp
}
  8013ec:	89 d0                	mov    %edx,%eax
  8013ee:	c9                   	leave  
  8013ef:	c3                   	ret    

008013f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	56                   	push   %esi
  8013f4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013f5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013f8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013fe:	e8 45 ed ff ff       	call   800148 <sys_getenvid>
  801403:	83 ec 0c             	sub    $0xc,%esp
  801406:	ff 75 0c             	pushl  0xc(%ebp)
  801409:	ff 75 08             	pushl  0x8(%ebp)
  80140c:	56                   	push   %esi
  80140d:	50                   	push   %eax
  80140e:	68 c0 23 80 00       	push   $0x8023c0
  801413:	e8 b1 00 00 00       	call   8014c9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801418:	83 c4 18             	add    $0x18,%esp
  80141b:	53                   	push   %ebx
  80141c:	ff 75 10             	pushl  0x10(%ebp)
  80141f:	e8 54 00 00 00       	call   801478 <vcprintf>
	cprintf("\n");
  801424:	c7 04 24 ab 23 80 00 	movl   $0x8023ab,(%esp)
  80142b:	e8 99 00 00 00       	call   8014c9 <cprintf>
  801430:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801433:	cc                   	int3   
  801434:	eb fd                	jmp    801433 <_panic+0x43>

00801436 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	53                   	push   %ebx
  80143a:	83 ec 04             	sub    $0x4,%esp
  80143d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801440:	8b 13                	mov    (%ebx),%edx
  801442:	8d 42 01             	lea    0x1(%edx),%eax
  801445:	89 03                	mov    %eax,(%ebx)
  801447:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80144a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80144e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801453:	75 1a                	jne    80146f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	68 ff 00 00 00       	push   $0xff
  80145d:	8d 43 08             	lea    0x8(%ebx),%eax
  801460:	50                   	push   %eax
  801461:	e8 64 ec ff ff       	call   8000ca <sys_cputs>
		b->idx = 0;
  801466:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80146c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80146f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801473:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801476:	c9                   	leave  
  801477:	c3                   	ret    

00801478 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801481:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801488:	00 00 00 
	b.cnt = 0;
  80148b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801492:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801495:	ff 75 0c             	pushl  0xc(%ebp)
  801498:	ff 75 08             	pushl  0x8(%ebp)
  80149b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8014a1:	50                   	push   %eax
  8014a2:	68 36 14 80 00       	push   $0x801436
  8014a7:	e8 54 01 00 00       	call   801600 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8014ac:	83 c4 08             	add    $0x8,%esp
  8014af:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8014b5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	e8 09 ec ff ff       	call   8000ca <sys_cputs>

	return b.cnt;
}
  8014c1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014c7:	c9                   	leave  
  8014c8:	c3                   	ret    

008014c9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014cf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8014d2:	50                   	push   %eax
  8014d3:	ff 75 08             	pushl  0x8(%ebp)
  8014d6:	e8 9d ff ff ff       	call   801478 <vcprintf>
	va_end(ap);

	return cnt;
}
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	57                   	push   %edi
  8014e1:	56                   	push   %esi
  8014e2:	53                   	push   %ebx
  8014e3:	83 ec 1c             	sub    $0x1c,%esp
  8014e6:	89 c7                	mov    %eax,%edi
  8014e8:	89 d6                	mov    %edx,%esi
  8014ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014fe:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801501:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801504:	39 d3                	cmp    %edx,%ebx
  801506:	72 05                	jb     80150d <printnum+0x30>
  801508:	39 45 10             	cmp    %eax,0x10(%ebp)
  80150b:	77 45                	ja     801552 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80150d:	83 ec 0c             	sub    $0xc,%esp
  801510:	ff 75 18             	pushl  0x18(%ebp)
  801513:	8b 45 14             	mov    0x14(%ebp),%eax
  801516:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801519:	53                   	push   %ebx
  80151a:	ff 75 10             	pushl  0x10(%ebp)
  80151d:	83 ec 08             	sub    $0x8,%esp
  801520:	ff 75 e4             	pushl  -0x1c(%ebp)
  801523:	ff 75 e0             	pushl  -0x20(%ebp)
  801526:	ff 75 dc             	pushl  -0x24(%ebp)
  801529:	ff 75 d8             	pushl  -0x28(%ebp)
  80152c:	e8 5f 0a 00 00       	call   801f90 <__udivdi3>
  801531:	83 c4 18             	add    $0x18,%esp
  801534:	52                   	push   %edx
  801535:	50                   	push   %eax
  801536:	89 f2                	mov    %esi,%edx
  801538:	89 f8                	mov    %edi,%eax
  80153a:	e8 9e ff ff ff       	call   8014dd <printnum>
  80153f:	83 c4 20             	add    $0x20,%esp
  801542:	eb 18                	jmp    80155c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	56                   	push   %esi
  801548:	ff 75 18             	pushl  0x18(%ebp)
  80154b:	ff d7                	call   *%edi
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	eb 03                	jmp    801555 <printnum+0x78>
  801552:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801555:	83 eb 01             	sub    $0x1,%ebx
  801558:	85 db                	test   %ebx,%ebx
  80155a:	7f e8                	jg     801544 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80155c:	83 ec 08             	sub    $0x8,%esp
  80155f:	56                   	push   %esi
  801560:	83 ec 04             	sub    $0x4,%esp
  801563:	ff 75 e4             	pushl  -0x1c(%ebp)
  801566:	ff 75 e0             	pushl  -0x20(%ebp)
  801569:	ff 75 dc             	pushl  -0x24(%ebp)
  80156c:	ff 75 d8             	pushl  -0x28(%ebp)
  80156f:	e8 4c 0b 00 00       	call   8020c0 <__umoddi3>
  801574:	83 c4 14             	add    $0x14,%esp
  801577:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  80157e:	50                   	push   %eax
  80157f:	ff d7                	call   *%edi
}
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801587:	5b                   	pop    %ebx
  801588:	5e                   	pop    %esi
  801589:	5f                   	pop    %edi
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    

0080158c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80158f:	83 fa 01             	cmp    $0x1,%edx
  801592:	7e 0e                	jle    8015a2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801594:	8b 10                	mov    (%eax),%edx
  801596:	8d 4a 08             	lea    0x8(%edx),%ecx
  801599:	89 08                	mov    %ecx,(%eax)
  80159b:	8b 02                	mov    (%edx),%eax
  80159d:	8b 52 04             	mov    0x4(%edx),%edx
  8015a0:	eb 22                	jmp    8015c4 <getuint+0x38>
	else if (lflag)
  8015a2:	85 d2                	test   %edx,%edx
  8015a4:	74 10                	je     8015b6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8015a6:	8b 10                	mov    (%eax),%edx
  8015a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015ab:	89 08                	mov    %ecx,(%eax)
  8015ad:	8b 02                	mov    (%edx),%eax
  8015af:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b4:	eb 0e                	jmp    8015c4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8015b6:	8b 10                	mov    (%eax),%edx
  8015b8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015bb:	89 08                	mov    %ecx,(%eax)
  8015bd:	8b 02                	mov    (%edx),%eax
  8015bf:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8015c4:	5d                   	pop    %ebp
  8015c5:	c3                   	ret    

008015c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015cc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8015d0:	8b 10                	mov    (%eax),%edx
  8015d2:	3b 50 04             	cmp    0x4(%eax),%edx
  8015d5:	73 0a                	jae    8015e1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8015d7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8015da:	89 08                	mov    %ecx,(%eax)
  8015dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015df:	88 02                	mov    %al,(%edx)
}
  8015e1:	5d                   	pop    %ebp
  8015e2:	c3                   	ret    

008015e3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
  8015e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8015e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015ec:	50                   	push   %eax
  8015ed:	ff 75 10             	pushl  0x10(%ebp)
  8015f0:	ff 75 0c             	pushl  0xc(%ebp)
  8015f3:	ff 75 08             	pushl  0x8(%ebp)
  8015f6:	e8 05 00 00 00       	call   801600 <vprintfmt>
	va_end(ap);
}
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	57                   	push   %edi
  801604:	56                   	push   %esi
  801605:	53                   	push   %ebx
  801606:	83 ec 2c             	sub    $0x2c,%esp
  801609:	8b 75 08             	mov    0x8(%ebp),%esi
  80160c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80160f:	8b 7d 10             	mov    0x10(%ebp),%edi
  801612:	eb 12                	jmp    801626 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801614:	85 c0                	test   %eax,%eax
  801616:	0f 84 89 03 00 00    	je     8019a5 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	53                   	push   %ebx
  801620:	50                   	push   %eax
  801621:	ff d6                	call   *%esi
  801623:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801626:	83 c7 01             	add    $0x1,%edi
  801629:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80162d:	83 f8 25             	cmp    $0x25,%eax
  801630:	75 e2                	jne    801614 <vprintfmt+0x14>
  801632:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801636:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80163d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801644:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80164b:	ba 00 00 00 00       	mov    $0x0,%edx
  801650:	eb 07                	jmp    801659 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801652:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801655:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801659:	8d 47 01             	lea    0x1(%edi),%eax
  80165c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80165f:	0f b6 07             	movzbl (%edi),%eax
  801662:	0f b6 c8             	movzbl %al,%ecx
  801665:	83 e8 23             	sub    $0x23,%eax
  801668:	3c 55                	cmp    $0x55,%al
  80166a:	0f 87 1a 03 00 00    	ja     80198a <vprintfmt+0x38a>
  801670:	0f b6 c0             	movzbl %al,%eax
  801673:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80167a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80167d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801681:	eb d6                	jmp    801659 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801683:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801686:	b8 00 00 00 00       	mov    $0x0,%eax
  80168b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80168e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801691:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801695:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801698:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80169b:	83 fa 09             	cmp    $0x9,%edx
  80169e:	77 39                	ja     8016d9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8016a0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8016a3:	eb e9                	jmp    80168e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8016a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a8:	8d 48 04             	lea    0x4(%eax),%ecx
  8016ab:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8016ae:	8b 00                	mov    (%eax),%eax
  8016b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8016b6:	eb 27                	jmp    8016df <vprintfmt+0xdf>
  8016b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016c2:	0f 49 c8             	cmovns %eax,%ecx
  8016c5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016cb:	eb 8c                	jmp    801659 <vprintfmt+0x59>
  8016cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8016d0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8016d7:	eb 80                	jmp    801659 <vprintfmt+0x59>
  8016d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016dc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8016df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016e3:	0f 89 70 ff ff ff    	jns    801659 <vprintfmt+0x59>
				width = precision, precision = -1;
  8016e9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8016ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016ef:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016f6:	e9 5e ff ff ff       	jmp    801659 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016fb:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801701:	e9 53 ff ff ff       	jmp    801659 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801706:	8b 45 14             	mov    0x14(%ebp),%eax
  801709:	8d 50 04             	lea    0x4(%eax),%edx
  80170c:	89 55 14             	mov    %edx,0x14(%ebp)
  80170f:	83 ec 08             	sub    $0x8,%esp
  801712:	53                   	push   %ebx
  801713:	ff 30                	pushl  (%eax)
  801715:	ff d6                	call   *%esi
			break;
  801717:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80171a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80171d:	e9 04 ff ff ff       	jmp    801626 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801722:	8b 45 14             	mov    0x14(%ebp),%eax
  801725:	8d 50 04             	lea    0x4(%eax),%edx
  801728:	89 55 14             	mov    %edx,0x14(%ebp)
  80172b:	8b 00                	mov    (%eax),%eax
  80172d:	99                   	cltd   
  80172e:	31 d0                	xor    %edx,%eax
  801730:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801732:	83 f8 0f             	cmp    $0xf,%eax
  801735:	7f 0b                	jg     801742 <vprintfmt+0x142>
  801737:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80173e:	85 d2                	test   %edx,%edx
  801740:	75 18                	jne    80175a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801742:	50                   	push   %eax
  801743:	68 fb 23 80 00       	push   $0x8023fb
  801748:	53                   	push   %ebx
  801749:	56                   	push   %esi
  80174a:	e8 94 fe ff ff       	call   8015e3 <printfmt>
  80174f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801752:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801755:	e9 cc fe ff ff       	jmp    801626 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80175a:	52                   	push   %edx
  80175b:	68 79 23 80 00       	push   $0x802379
  801760:	53                   	push   %ebx
  801761:	56                   	push   %esi
  801762:	e8 7c fe ff ff       	call   8015e3 <printfmt>
  801767:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80176a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80176d:	e9 b4 fe ff ff       	jmp    801626 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801772:	8b 45 14             	mov    0x14(%ebp),%eax
  801775:	8d 50 04             	lea    0x4(%eax),%edx
  801778:	89 55 14             	mov    %edx,0x14(%ebp)
  80177b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80177d:	85 ff                	test   %edi,%edi
  80177f:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  801784:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801787:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80178b:	0f 8e 94 00 00 00    	jle    801825 <vprintfmt+0x225>
  801791:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801795:	0f 84 98 00 00 00    	je     801833 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80179b:	83 ec 08             	sub    $0x8,%esp
  80179e:	ff 75 d0             	pushl  -0x30(%ebp)
  8017a1:	57                   	push   %edi
  8017a2:	e8 86 02 00 00       	call   801a2d <strnlen>
  8017a7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8017aa:	29 c1                	sub    %eax,%ecx
  8017ac:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8017af:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8017b2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8017b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017b9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017bc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017be:	eb 0f                	jmp    8017cf <vprintfmt+0x1cf>
					putch(padc, putdat);
  8017c0:	83 ec 08             	sub    $0x8,%esp
  8017c3:	53                   	push   %ebx
  8017c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8017c7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017c9:	83 ef 01             	sub    $0x1,%edi
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	85 ff                	test   %edi,%edi
  8017d1:	7f ed                	jg     8017c0 <vprintfmt+0x1c0>
  8017d3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017d6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8017d9:	85 c9                	test   %ecx,%ecx
  8017db:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e0:	0f 49 c1             	cmovns %ecx,%eax
  8017e3:	29 c1                	sub    %eax,%ecx
  8017e5:	89 75 08             	mov    %esi,0x8(%ebp)
  8017e8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017ee:	89 cb                	mov    %ecx,%ebx
  8017f0:	eb 4d                	jmp    80183f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017f2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017f6:	74 1b                	je     801813 <vprintfmt+0x213>
  8017f8:	0f be c0             	movsbl %al,%eax
  8017fb:	83 e8 20             	sub    $0x20,%eax
  8017fe:	83 f8 5e             	cmp    $0x5e,%eax
  801801:	76 10                	jbe    801813 <vprintfmt+0x213>
					putch('?', putdat);
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	ff 75 0c             	pushl  0xc(%ebp)
  801809:	6a 3f                	push   $0x3f
  80180b:	ff 55 08             	call   *0x8(%ebp)
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	eb 0d                	jmp    801820 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801813:	83 ec 08             	sub    $0x8,%esp
  801816:	ff 75 0c             	pushl  0xc(%ebp)
  801819:	52                   	push   %edx
  80181a:	ff 55 08             	call   *0x8(%ebp)
  80181d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801820:	83 eb 01             	sub    $0x1,%ebx
  801823:	eb 1a                	jmp    80183f <vprintfmt+0x23f>
  801825:	89 75 08             	mov    %esi,0x8(%ebp)
  801828:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80182b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80182e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801831:	eb 0c                	jmp    80183f <vprintfmt+0x23f>
  801833:	89 75 08             	mov    %esi,0x8(%ebp)
  801836:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801839:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80183c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80183f:	83 c7 01             	add    $0x1,%edi
  801842:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801846:	0f be d0             	movsbl %al,%edx
  801849:	85 d2                	test   %edx,%edx
  80184b:	74 23                	je     801870 <vprintfmt+0x270>
  80184d:	85 f6                	test   %esi,%esi
  80184f:	78 a1                	js     8017f2 <vprintfmt+0x1f2>
  801851:	83 ee 01             	sub    $0x1,%esi
  801854:	79 9c                	jns    8017f2 <vprintfmt+0x1f2>
  801856:	89 df                	mov    %ebx,%edi
  801858:	8b 75 08             	mov    0x8(%ebp),%esi
  80185b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80185e:	eb 18                	jmp    801878 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801860:	83 ec 08             	sub    $0x8,%esp
  801863:	53                   	push   %ebx
  801864:	6a 20                	push   $0x20
  801866:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801868:	83 ef 01             	sub    $0x1,%edi
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	eb 08                	jmp    801878 <vprintfmt+0x278>
  801870:	89 df                	mov    %ebx,%edi
  801872:	8b 75 08             	mov    0x8(%ebp),%esi
  801875:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801878:	85 ff                	test   %edi,%edi
  80187a:	7f e4                	jg     801860 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80187c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80187f:	e9 a2 fd ff ff       	jmp    801626 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801884:	83 fa 01             	cmp    $0x1,%edx
  801887:	7e 16                	jle    80189f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801889:	8b 45 14             	mov    0x14(%ebp),%eax
  80188c:	8d 50 08             	lea    0x8(%eax),%edx
  80188f:	89 55 14             	mov    %edx,0x14(%ebp)
  801892:	8b 50 04             	mov    0x4(%eax),%edx
  801895:	8b 00                	mov    (%eax),%eax
  801897:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80189a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80189d:	eb 32                	jmp    8018d1 <vprintfmt+0x2d1>
	else if (lflag)
  80189f:	85 d2                	test   %edx,%edx
  8018a1:	74 18                	je     8018bb <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8018a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8018a6:	8d 50 04             	lea    0x4(%eax),%edx
  8018a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8018ac:	8b 00                	mov    (%eax),%eax
  8018ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018b1:	89 c1                	mov    %eax,%ecx
  8018b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8018b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018b9:	eb 16                	jmp    8018d1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8018bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8018be:	8d 50 04             	lea    0x4(%eax),%edx
  8018c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8018c4:	8b 00                	mov    (%eax),%eax
  8018c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018c9:	89 c1                	mov    %eax,%ecx
  8018cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8018ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8018d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8018d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8018dc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018e0:	79 74                	jns    801956 <vprintfmt+0x356>
				putch('-', putdat);
  8018e2:	83 ec 08             	sub    $0x8,%esp
  8018e5:	53                   	push   %ebx
  8018e6:	6a 2d                	push   $0x2d
  8018e8:	ff d6                	call   *%esi
				num = -(long long) num;
  8018ea:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8018f0:	f7 d8                	neg    %eax
  8018f2:	83 d2 00             	adc    $0x0,%edx
  8018f5:	f7 da                	neg    %edx
  8018f7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018fa:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018ff:	eb 55                	jmp    801956 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801901:	8d 45 14             	lea    0x14(%ebp),%eax
  801904:	e8 83 fc ff ff       	call   80158c <getuint>
			base = 10;
  801909:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80190e:	eb 46                	jmp    801956 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801910:	8d 45 14             	lea    0x14(%ebp),%eax
  801913:	e8 74 fc ff ff       	call   80158c <getuint>
			base = 8;
  801918:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80191d:	eb 37                	jmp    801956 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80191f:	83 ec 08             	sub    $0x8,%esp
  801922:	53                   	push   %ebx
  801923:	6a 30                	push   $0x30
  801925:	ff d6                	call   *%esi
			putch('x', putdat);
  801927:	83 c4 08             	add    $0x8,%esp
  80192a:	53                   	push   %ebx
  80192b:	6a 78                	push   $0x78
  80192d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80192f:	8b 45 14             	mov    0x14(%ebp),%eax
  801932:	8d 50 04             	lea    0x4(%eax),%edx
  801935:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801938:	8b 00                	mov    (%eax),%eax
  80193a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80193f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801942:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801947:	eb 0d                	jmp    801956 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801949:	8d 45 14             	lea    0x14(%ebp),%eax
  80194c:	e8 3b fc ff ff       	call   80158c <getuint>
			base = 16;
  801951:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801956:	83 ec 0c             	sub    $0xc,%esp
  801959:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80195d:	57                   	push   %edi
  80195e:	ff 75 e0             	pushl  -0x20(%ebp)
  801961:	51                   	push   %ecx
  801962:	52                   	push   %edx
  801963:	50                   	push   %eax
  801964:	89 da                	mov    %ebx,%edx
  801966:	89 f0                	mov    %esi,%eax
  801968:	e8 70 fb ff ff       	call   8014dd <printnum>
			break;
  80196d:	83 c4 20             	add    $0x20,%esp
  801970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801973:	e9 ae fc ff ff       	jmp    801626 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801978:	83 ec 08             	sub    $0x8,%esp
  80197b:	53                   	push   %ebx
  80197c:	51                   	push   %ecx
  80197d:	ff d6                	call   *%esi
			break;
  80197f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801982:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801985:	e9 9c fc ff ff       	jmp    801626 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80198a:	83 ec 08             	sub    $0x8,%esp
  80198d:	53                   	push   %ebx
  80198e:	6a 25                	push   $0x25
  801990:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	eb 03                	jmp    80199a <vprintfmt+0x39a>
  801997:	83 ef 01             	sub    $0x1,%edi
  80199a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80199e:	75 f7                	jne    801997 <vprintfmt+0x397>
  8019a0:	e9 81 fc ff ff       	jmp    801626 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8019a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a8:	5b                   	pop    %ebx
  8019a9:	5e                   	pop    %esi
  8019aa:	5f                   	pop    %edi
  8019ab:	5d                   	pop    %ebp
  8019ac:	c3                   	ret    

008019ad <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	83 ec 18             	sub    $0x18,%esp
  8019b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8019c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8019c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	74 26                	je     8019f4 <vsnprintf+0x47>
  8019ce:	85 d2                	test   %edx,%edx
  8019d0:	7e 22                	jle    8019f4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8019d2:	ff 75 14             	pushl  0x14(%ebp)
  8019d5:	ff 75 10             	pushl  0x10(%ebp)
  8019d8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019db:	50                   	push   %eax
  8019dc:	68 c6 15 80 00       	push   $0x8015c6
  8019e1:	e8 1a fc ff ff       	call   801600 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	eb 05                	jmp    8019f9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019f9:	c9                   	leave  
  8019fa:	c3                   	ret    

008019fb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a01:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a04:	50                   	push   %eax
  801a05:	ff 75 10             	pushl  0x10(%ebp)
  801a08:	ff 75 0c             	pushl  0xc(%ebp)
  801a0b:	ff 75 08             	pushl  0x8(%ebp)
  801a0e:	e8 9a ff ff ff       	call   8019ad <vsnprintf>
	va_end(ap);

	return rc;
}
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    

00801a15 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a20:	eb 03                	jmp    801a25 <strlen+0x10>
		n++;
  801a22:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a25:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a29:	75 f7                	jne    801a22 <strlen+0xd>
		n++;
	return n;
}
  801a2b:	5d                   	pop    %ebp
  801a2c:	c3                   	ret    

00801a2d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a33:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a36:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3b:	eb 03                	jmp    801a40 <strnlen+0x13>
		n++;
  801a3d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a40:	39 c2                	cmp    %eax,%edx
  801a42:	74 08                	je     801a4c <strnlen+0x1f>
  801a44:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801a48:	75 f3                	jne    801a3d <strnlen+0x10>
  801a4a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a4c:	5d                   	pop    %ebp
  801a4d:	c3                   	ret    

00801a4e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	53                   	push   %ebx
  801a52:	8b 45 08             	mov    0x8(%ebp),%eax
  801a55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a58:	89 c2                	mov    %eax,%edx
  801a5a:	83 c2 01             	add    $0x1,%edx
  801a5d:	83 c1 01             	add    $0x1,%ecx
  801a60:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a64:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a67:	84 db                	test   %bl,%bl
  801a69:	75 ef                	jne    801a5a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a6b:	5b                   	pop    %ebx
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	53                   	push   %ebx
  801a72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a75:	53                   	push   %ebx
  801a76:	e8 9a ff ff ff       	call   801a15 <strlen>
  801a7b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a7e:	ff 75 0c             	pushl  0xc(%ebp)
  801a81:	01 d8                	add    %ebx,%eax
  801a83:	50                   	push   %eax
  801a84:	e8 c5 ff ff ff       	call   801a4e <strcpy>
	return dst;
}
  801a89:	89 d8                	mov    %ebx,%eax
  801a8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	56                   	push   %esi
  801a94:	53                   	push   %ebx
  801a95:	8b 75 08             	mov    0x8(%ebp),%esi
  801a98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9b:	89 f3                	mov    %esi,%ebx
  801a9d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801aa0:	89 f2                	mov    %esi,%edx
  801aa2:	eb 0f                	jmp    801ab3 <strncpy+0x23>
		*dst++ = *src;
  801aa4:	83 c2 01             	add    $0x1,%edx
  801aa7:	0f b6 01             	movzbl (%ecx),%eax
  801aaa:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801aad:	80 39 01             	cmpb   $0x1,(%ecx)
  801ab0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ab3:	39 da                	cmp    %ebx,%edx
  801ab5:	75 ed                	jne    801aa4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ab7:	89 f0                	mov    %esi,%eax
  801ab9:	5b                   	pop    %ebx
  801aba:	5e                   	pop    %esi
  801abb:	5d                   	pop    %ebp
  801abc:	c3                   	ret    

00801abd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac8:	8b 55 10             	mov    0x10(%ebp),%edx
  801acb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801acd:	85 d2                	test   %edx,%edx
  801acf:	74 21                	je     801af2 <strlcpy+0x35>
  801ad1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801ad5:	89 f2                	mov    %esi,%edx
  801ad7:	eb 09                	jmp    801ae2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801ad9:	83 c2 01             	add    $0x1,%edx
  801adc:	83 c1 01             	add    $0x1,%ecx
  801adf:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ae2:	39 c2                	cmp    %eax,%edx
  801ae4:	74 09                	je     801aef <strlcpy+0x32>
  801ae6:	0f b6 19             	movzbl (%ecx),%ebx
  801ae9:	84 db                	test   %bl,%bl
  801aeb:	75 ec                	jne    801ad9 <strlcpy+0x1c>
  801aed:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801aef:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801af2:	29 f0                	sub    %esi,%eax
}
  801af4:	5b                   	pop    %ebx
  801af5:	5e                   	pop    %esi
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    

00801af8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801afe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801b01:	eb 06                	jmp    801b09 <strcmp+0x11>
		p++, q++;
  801b03:	83 c1 01             	add    $0x1,%ecx
  801b06:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801b09:	0f b6 01             	movzbl (%ecx),%eax
  801b0c:	84 c0                	test   %al,%al
  801b0e:	74 04                	je     801b14 <strcmp+0x1c>
  801b10:	3a 02                	cmp    (%edx),%al
  801b12:	74 ef                	je     801b03 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801b14:	0f b6 c0             	movzbl %al,%eax
  801b17:	0f b6 12             	movzbl (%edx),%edx
  801b1a:	29 d0                	sub    %edx,%eax
}
  801b1c:	5d                   	pop    %ebp
  801b1d:	c3                   	ret    

00801b1e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	53                   	push   %ebx
  801b22:	8b 45 08             	mov    0x8(%ebp),%eax
  801b25:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b28:	89 c3                	mov    %eax,%ebx
  801b2a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801b2d:	eb 06                	jmp    801b35 <strncmp+0x17>
		n--, p++, q++;
  801b2f:	83 c0 01             	add    $0x1,%eax
  801b32:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b35:	39 d8                	cmp    %ebx,%eax
  801b37:	74 15                	je     801b4e <strncmp+0x30>
  801b39:	0f b6 08             	movzbl (%eax),%ecx
  801b3c:	84 c9                	test   %cl,%cl
  801b3e:	74 04                	je     801b44 <strncmp+0x26>
  801b40:	3a 0a                	cmp    (%edx),%cl
  801b42:	74 eb                	je     801b2f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b44:	0f b6 00             	movzbl (%eax),%eax
  801b47:	0f b6 12             	movzbl (%edx),%edx
  801b4a:	29 d0                	sub    %edx,%eax
  801b4c:	eb 05                	jmp    801b53 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b4e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b53:	5b                   	pop    %ebx
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    

00801b56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b60:	eb 07                	jmp    801b69 <strchr+0x13>
		if (*s == c)
  801b62:	38 ca                	cmp    %cl,%dl
  801b64:	74 0f                	je     801b75 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b66:	83 c0 01             	add    $0x1,%eax
  801b69:	0f b6 10             	movzbl (%eax),%edx
  801b6c:	84 d2                	test   %dl,%dl
  801b6e:	75 f2                	jne    801b62 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b75:	5d                   	pop    %ebp
  801b76:	c3                   	ret    

00801b77 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b81:	eb 03                	jmp    801b86 <strfind+0xf>
  801b83:	83 c0 01             	add    $0x1,%eax
  801b86:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b89:	38 ca                	cmp    %cl,%dl
  801b8b:	74 04                	je     801b91 <strfind+0x1a>
  801b8d:	84 d2                	test   %dl,%dl
  801b8f:	75 f2                	jne    801b83 <strfind+0xc>
			break;
	return (char *) s;
}
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    

00801b93 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	57                   	push   %edi
  801b97:	56                   	push   %esi
  801b98:	53                   	push   %ebx
  801b99:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b9f:	85 c9                	test   %ecx,%ecx
  801ba1:	74 36                	je     801bd9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ba3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ba9:	75 28                	jne    801bd3 <memset+0x40>
  801bab:	f6 c1 03             	test   $0x3,%cl
  801bae:	75 23                	jne    801bd3 <memset+0x40>
		c &= 0xFF;
  801bb0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801bb4:	89 d3                	mov    %edx,%ebx
  801bb6:	c1 e3 08             	shl    $0x8,%ebx
  801bb9:	89 d6                	mov    %edx,%esi
  801bbb:	c1 e6 18             	shl    $0x18,%esi
  801bbe:	89 d0                	mov    %edx,%eax
  801bc0:	c1 e0 10             	shl    $0x10,%eax
  801bc3:	09 f0                	or     %esi,%eax
  801bc5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801bc7:	89 d8                	mov    %ebx,%eax
  801bc9:	09 d0                	or     %edx,%eax
  801bcb:	c1 e9 02             	shr    $0x2,%ecx
  801bce:	fc                   	cld    
  801bcf:	f3 ab                	rep stos %eax,%es:(%edi)
  801bd1:	eb 06                	jmp    801bd9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd6:	fc                   	cld    
  801bd7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801bd9:	89 f8                	mov    %edi,%eax
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5f                   	pop    %edi
  801bde:	5d                   	pop    %ebp
  801bdf:	c3                   	ret    

00801be0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	57                   	push   %edi
  801be4:	56                   	push   %esi
  801be5:	8b 45 08             	mov    0x8(%ebp),%eax
  801be8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801beb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801bee:	39 c6                	cmp    %eax,%esi
  801bf0:	73 35                	jae    801c27 <memmove+0x47>
  801bf2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801bf5:	39 d0                	cmp    %edx,%eax
  801bf7:	73 2e                	jae    801c27 <memmove+0x47>
		s += n;
		d += n;
  801bf9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bfc:	89 d6                	mov    %edx,%esi
  801bfe:	09 fe                	or     %edi,%esi
  801c00:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801c06:	75 13                	jne    801c1b <memmove+0x3b>
  801c08:	f6 c1 03             	test   $0x3,%cl
  801c0b:	75 0e                	jne    801c1b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801c0d:	83 ef 04             	sub    $0x4,%edi
  801c10:	8d 72 fc             	lea    -0x4(%edx),%esi
  801c13:	c1 e9 02             	shr    $0x2,%ecx
  801c16:	fd                   	std    
  801c17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c19:	eb 09                	jmp    801c24 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801c1b:	83 ef 01             	sub    $0x1,%edi
  801c1e:	8d 72 ff             	lea    -0x1(%edx),%esi
  801c21:	fd                   	std    
  801c22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801c24:	fc                   	cld    
  801c25:	eb 1d                	jmp    801c44 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c27:	89 f2                	mov    %esi,%edx
  801c29:	09 c2                	or     %eax,%edx
  801c2b:	f6 c2 03             	test   $0x3,%dl
  801c2e:	75 0f                	jne    801c3f <memmove+0x5f>
  801c30:	f6 c1 03             	test   $0x3,%cl
  801c33:	75 0a                	jne    801c3f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801c35:	c1 e9 02             	shr    $0x2,%ecx
  801c38:	89 c7                	mov    %eax,%edi
  801c3a:	fc                   	cld    
  801c3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c3d:	eb 05                	jmp    801c44 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c3f:	89 c7                	mov    %eax,%edi
  801c41:	fc                   	cld    
  801c42:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    

00801c48 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c4b:	ff 75 10             	pushl  0x10(%ebp)
  801c4e:	ff 75 0c             	pushl  0xc(%ebp)
  801c51:	ff 75 08             	pushl  0x8(%ebp)
  801c54:	e8 87 ff ff ff       	call   801be0 <memmove>
}
  801c59:	c9                   	leave  
  801c5a:	c3                   	ret    

00801c5b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	56                   	push   %esi
  801c5f:	53                   	push   %ebx
  801c60:	8b 45 08             	mov    0x8(%ebp),%eax
  801c63:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c66:	89 c6                	mov    %eax,%esi
  801c68:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c6b:	eb 1a                	jmp    801c87 <memcmp+0x2c>
		if (*s1 != *s2)
  801c6d:	0f b6 08             	movzbl (%eax),%ecx
  801c70:	0f b6 1a             	movzbl (%edx),%ebx
  801c73:	38 d9                	cmp    %bl,%cl
  801c75:	74 0a                	je     801c81 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c77:	0f b6 c1             	movzbl %cl,%eax
  801c7a:	0f b6 db             	movzbl %bl,%ebx
  801c7d:	29 d8                	sub    %ebx,%eax
  801c7f:	eb 0f                	jmp    801c90 <memcmp+0x35>
		s1++, s2++;
  801c81:	83 c0 01             	add    $0x1,%eax
  801c84:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c87:	39 f0                	cmp    %esi,%eax
  801c89:	75 e2                	jne    801c6d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c90:	5b                   	pop    %ebx
  801c91:	5e                   	pop    %esi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    

00801c94 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	53                   	push   %ebx
  801c98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c9b:	89 c1                	mov    %eax,%ecx
  801c9d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801ca0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ca4:	eb 0a                	jmp    801cb0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ca6:	0f b6 10             	movzbl (%eax),%edx
  801ca9:	39 da                	cmp    %ebx,%edx
  801cab:	74 07                	je     801cb4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801cad:	83 c0 01             	add    $0x1,%eax
  801cb0:	39 c8                	cmp    %ecx,%eax
  801cb2:	72 f2                	jb     801ca6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801cb4:	5b                   	pop    %ebx
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    

00801cb7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	57                   	push   %edi
  801cbb:	56                   	push   %esi
  801cbc:	53                   	push   %ebx
  801cbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cc3:	eb 03                	jmp    801cc8 <strtol+0x11>
		s++;
  801cc5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cc8:	0f b6 01             	movzbl (%ecx),%eax
  801ccb:	3c 20                	cmp    $0x20,%al
  801ccd:	74 f6                	je     801cc5 <strtol+0xe>
  801ccf:	3c 09                	cmp    $0x9,%al
  801cd1:	74 f2                	je     801cc5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801cd3:	3c 2b                	cmp    $0x2b,%al
  801cd5:	75 0a                	jne    801ce1 <strtol+0x2a>
		s++;
  801cd7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801cda:	bf 00 00 00 00       	mov    $0x0,%edi
  801cdf:	eb 11                	jmp    801cf2 <strtol+0x3b>
  801ce1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ce6:	3c 2d                	cmp    $0x2d,%al
  801ce8:	75 08                	jne    801cf2 <strtol+0x3b>
		s++, neg = 1;
  801cea:	83 c1 01             	add    $0x1,%ecx
  801ced:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801cf2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801cf8:	75 15                	jne    801d0f <strtol+0x58>
  801cfa:	80 39 30             	cmpb   $0x30,(%ecx)
  801cfd:	75 10                	jne    801d0f <strtol+0x58>
  801cff:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801d03:	75 7c                	jne    801d81 <strtol+0xca>
		s += 2, base = 16;
  801d05:	83 c1 02             	add    $0x2,%ecx
  801d08:	bb 10 00 00 00       	mov    $0x10,%ebx
  801d0d:	eb 16                	jmp    801d25 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801d0f:	85 db                	test   %ebx,%ebx
  801d11:	75 12                	jne    801d25 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801d13:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d18:	80 39 30             	cmpb   $0x30,(%ecx)
  801d1b:	75 08                	jne    801d25 <strtol+0x6e>
		s++, base = 8;
  801d1d:	83 c1 01             	add    $0x1,%ecx
  801d20:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801d25:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801d2d:	0f b6 11             	movzbl (%ecx),%edx
  801d30:	8d 72 d0             	lea    -0x30(%edx),%esi
  801d33:	89 f3                	mov    %esi,%ebx
  801d35:	80 fb 09             	cmp    $0x9,%bl
  801d38:	77 08                	ja     801d42 <strtol+0x8b>
			dig = *s - '0';
  801d3a:	0f be d2             	movsbl %dl,%edx
  801d3d:	83 ea 30             	sub    $0x30,%edx
  801d40:	eb 22                	jmp    801d64 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801d42:	8d 72 9f             	lea    -0x61(%edx),%esi
  801d45:	89 f3                	mov    %esi,%ebx
  801d47:	80 fb 19             	cmp    $0x19,%bl
  801d4a:	77 08                	ja     801d54 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d4c:	0f be d2             	movsbl %dl,%edx
  801d4f:	83 ea 57             	sub    $0x57,%edx
  801d52:	eb 10                	jmp    801d64 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d54:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d57:	89 f3                	mov    %esi,%ebx
  801d59:	80 fb 19             	cmp    $0x19,%bl
  801d5c:	77 16                	ja     801d74 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d5e:	0f be d2             	movsbl %dl,%edx
  801d61:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d64:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d67:	7d 0b                	jge    801d74 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d69:	83 c1 01             	add    $0x1,%ecx
  801d6c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d70:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d72:	eb b9                	jmp    801d2d <strtol+0x76>

	if (endptr)
  801d74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d78:	74 0d                	je     801d87 <strtol+0xd0>
		*endptr = (char *) s;
  801d7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d7d:	89 0e                	mov    %ecx,(%esi)
  801d7f:	eb 06                	jmp    801d87 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d81:	85 db                	test   %ebx,%ebx
  801d83:	74 98                	je     801d1d <strtol+0x66>
  801d85:	eb 9e                	jmp    801d25 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d87:	89 c2                	mov    %eax,%edx
  801d89:	f7 da                	neg    %edx
  801d8b:	85 ff                	test   %edi,%edi
  801d8d:	0f 45 c2             	cmovne %edx,%eax
}
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d9b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801da2:	75 2a                	jne    801dce <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801da4:	83 ec 04             	sub    $0x4,%esp
  801da7:	6a 07                	push   $0x7
  801da9:	68 00 f0 bf ee       	push   $0xeebff000
  801dae:	6a 00                	push   $0x0
  801db0:	e8 d1 e3 ff ff       	call   800186 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	85 c0                	test   %eax,%eax
  801dba:	79 12                	jns    801dce <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801dbc:	50                   	push   %eax
  801dbd:	68 e0 26 80 00       	push   $0x8026e0
  801dc2:	6a 23                	push   $0x23
  801dc4:	68 e4 26 80 00       	push   $0x8026e4
  801dc9:	e8 22 f6 ff ff       	call   8013f0 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dce:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd1:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801dd6:	83 ec 08             	sub    $0x8,%esp
  801dd9:	68 00 1e 80 00       	push   $0x801e00
  801dde:	6a 00                	push   $0x0
  801de0:	e8 ec e4 ff ff       	call   8002d1 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801de5:	83 c4 10             	add    $0x10,%esp
  801de8:	85 c0                	test   %eax,%eax
  801dea:	79 12                	jns    801dfe <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801dec:	50                   	push   %eax
  801ded:	68 e0 26 80 00       	push   $0x8026e0
  801df2:	6a 2c                	push   $0x2c
  801df4:	68 e4 26 80 00       	push   $0x8026e4
  801df9:	e8 f2 f5 ff ff       	call   8013f0 <_panic>
	}
}
  801dfe:	c9                   	leave  
  801dff:	c3                   	ret    

00801e00 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e00:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e01:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e06:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e08:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e0b:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e0f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e14:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e18:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e1a:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e1d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e1e:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e21:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e22:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e23:	c3                   	ret    

00801e24 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
  801e27:	56                   	push   %esi
  801e28:	53                   	push   %ebx
  801e29:	8b 75 08             	mov    0x8(%ebp),%esi
  801e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e32:	85 c0                	test   %eax,%eax
  801e34:	75 12                	jne    801e48 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e36:	83 ec 0c             	sub    $0xc,%esp
  801e39:	68 00 00 c0 ee       	push   $0xeec00000
  801e3e:	e8 f3 e4 ff ff       	call   800336 <sys_ipc_recv>
  801e43:	83 c4 10             	add    $0x10,%esp
  801e46:	eb 0c                	jmp    801e54 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e48:	83 ec 0c             	sub    $0xc,%esp
  801e4b:	50                   	push   %eax
  801e4c:	e8 e5 e4 ff ff       	call   800336 <sys_ipc_recv>
  801e51:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e54:	85 f6                	test   %esi,%esi
  801e56:	0f 95 c1             	setne  %cl
  801e59:	85 db                	test   %ebx,%ebx
  801e5b:	0f 95 c2             	setne  %dl
  801e5e:	84 d1                	test   %dl,%cl
  801e60:	74 09                	je     801e6b <ipc_recv+0x47>
  801e62:	89 c2                	mov    %eax,%edx
  801e64:	c1 ea 1f             	shr    $0x1f,%edx
  801e67:	84 d2                	test   %dl,%dl
  801e69:	75 2d                	jne    801e98 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e6b:	85 f6                	test   %esi,%esi
  801e6d:	74 0d                	je     801e7c <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e6f:	a1 04 40 80 00       	mov    0x804004,%eax
  801e74:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801e7a:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e7c:	85 db                	test   %ebx,%ebx
  801e7e:	74 0d                	je     801e8d <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e80:	a1 04 40 80 00       	mov    0x804004,%eax
  801e85:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801e8b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e8d:	a1 04 40 80 00       	mov    0x804004,%eax
  801e92:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801e98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e9b:	5b                   	pop    %ebx
  801e9c:	5e                   	pop    %esi
  801e9d:	5d                   	pop    %ebp
  801e9e:	c3                   	ret    

00801e9f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	57                   	push   %edi
  801ea3:	56                   	push   %esi
  801ea4:	53                   	push   %ebx
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eab:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801eb1:	85 db                	test   %ebx,%ebx
  801eb3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801eb8:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ebb:	ff 75 14             	pushl  0x14(%ebp)
  801ebe:	53                   	push   %ebx
  801ebf:	56                   	push   %esi
  801ec0:	57                   	push   %edi
  801ec1:	e8 4d e4 ff ff       	call   800313 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ec6:	89 c2                	mov    %eax,%edx
  801ec8:	c1 ea 1f             	shr    $0x1f,%edx
  801ecb:	83 c4 10             	add    $0x10,%esp
  801ece:	84 d2                	test   %dl,%dl
  801ed0:	74 17                	je     801ee9 <ipc_send+0x4a>
  801ed2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ed5:	74 12                	je     801ee9 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ed7:	50                   	push   %eax
  801ed8:	68 f2 26 80 00       	push   $0x8026f2
  801edd:	6a 47                	push   $0x47
  801edf:	68 00 27 80 00       	push   $0x802700
  801ee4:	e8 07 f5 ff ff       	call   8013f0 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ee9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eec:	75 07                	jne    801ef5 <ipc_send+0x56>
			sys_yield();
  801eee:	e8 74 e2 ff ff       	call   800167 <sys_yield>
  801ef3:	eb c6                	jmp    801ebb <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	75 c2                	jne    801ebb <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ef9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801efc:	5b                   	pop    %ebx
  801efd:	5e                   	pop    %esi
  801efe:	5f                   	pop    %edi
  801eff:	5d                   	pop    %ebp
  801f00:	c3                   	ret    

00801f01 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
  801f04:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f07:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f0c:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801f12:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f18:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801f1e:	39 ca                	cmp    %ecx,%edx
  801f20:	75 13                	jne    801f35 <ipc_find_env+0x34>
			return envs[i].env_id;
  801f22:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801f28:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f2d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801f33:	eb 0f                	jmp    801f44 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f35:	83 c0 01             	add    $0x1,%eax
  801f38:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f3d:	75 cd                	jne    801f0c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f44:	5d                   	pop    %ebp
  801f45:	c3                   	ret    

00801f46 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f4c:	89 d0                	mov    %edx,%eax
  801f4e:	c1 e8 16             	shr    $0x16,%eax
  801f51:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f58:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5d:	f6 c1 01             	test   $0x1,%cl
  801f60:	74 1d                	je     801f7f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f62:	c1 ea 0c             	shr    $0xc,%edx
  801f65:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f6c:	f6 c2 01             	test   $0x1,%dl
  801f6f:	74 0e                	je     801f7f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f71:	c1 ea 0c             	shr    $0xc,%edx
  801f74:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f7b:	ef 
  801f7c:	0f b7 c0             	movzwl %ax,%eax
}
  801f7f:	5d                   	pop    %ebp
  801f80:	c3                   	ret    
  801f81:	66 90                	xchg   %ax,%ax
  801f83:	66 90                	xchg   %ax,%ax
  801f85:	66 90                	xchg   %ax,%ax
  801f87:	66 90                	xchg   %ax,%ax
  801f89:	66 90                	xchg   %ax,%ax
  801f8b:	66 90                	xchg   %ax,%ax
  801f8d:	66 90                	xchg   %ax,%ax
  801f8f:	90                   	nop

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
