
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
  8000b6:	e8 66 0a 00 00       	call   800b21 <close_all>
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
  80012f:	68 8a 24 80 00       	push   $0x80248a
  800134:	6a 23                	push   $0x23
  800136:	68 a7 24 80 00       	push   $0x8024a7
  80013b:	e8 12 15 00 00       	call   801652 <_panic>

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
  8001b0:	68 8a 24 80 00       	push   $0x80248a
  8001b5:	6a 23                	push   $0x23
  8001b7:	68 a7 24 80 00       	push   $0x8024a7
  8001bc:	e8 91 14 00 00       	call   801652 <_panic>

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
  8001f2:	68 8a 24 80 00       	push   $0x80248a
  8001f7:	6a 23                	push   $0x23
  8001f9:	68 a7 24 80 00       	push   $0x8024a7
  8001fe:	e8 4f 14 00 00       	call   801652 <_panic>

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
  800234:	68 8a 24 80 00       	push   $0x80248a
  800239:	6a 23                	push   $0x23
  80023b:	68 a7 24 80 00       	push   $0x8024a7
  800240:	e8 0d 14 00 00       	call   801652 <_panic>

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
  800276:	68 8a 24 80 00       	push   $0x80248a
  80027b:	6a 23                	push   $0x23
  80027d:	68 a7 24 80 00       	push   $0x8024a7
  800282:	e8 cb 13 00 00       	call   801652 <_panic>

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
  8002b8:	68 8a 24 80 00       	push   $0x80248a
  8002bd:	6a 23                	push   $0x23
  8002bf:	68 a7 24 80 00       	push   $0x8024a7
  8002c4:	e8 89 13 00 00       	call   801652 <_panic>
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
  8002fa:	68 8a 24 80 00       	push   $0x80248a
  8002ff:	6a 23                	push   $0x23
  800301:	68 a7 24 80 00       	push   $0x8024a7
  800306:	e8 47 13 00 00       	call   801652 <_panic>

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
  80035e:	68 8a 24 80 00       	push   $0x80248a
  800363:	6a 23                	push   $0x23
  800365:	68 a7 24 80 00       	push   $0x8024a7
  80036a:	e8 e3 12 00 00       	call   801652 <_panic>

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
  8003fd:	68 b5 24 80 00       	push   $0x8024b5
  800402:	6a 1f                	push   $0x1f
  800404:	68 c5 24 80 00       	push   $0x8024c5
  800409:	e8 44 12 00 00       	call   801652 <_panic>
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
  800427:	68 d0 24 80 00       	push   $0x8024d0
  80042c:	6a 2d                	push   $0x2d
  80042e:	68 c5 24 80 00       	push   $0x8024c5
  800433:	e8 1a 12 00 00       	call   801652 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800438:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80043e:	83 ec 04             	sub    $0x4,%esp
  800441:	68 00 10 00 00       	push   $0x1000
  800446:	53                   	push   %ebx
  800447:	68 00 f0 7f 00       	push   $0x7ff000
  80044c:	e8 59 1a 00 00       	call   801eaa <memcpy>

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
  80046f:	68 d0 24 80 00       	push   $0x8024d0
  800474:	6a 34                	push   $0x34
  800476:	68 c5 24 80 00       	push   $0x8024c5
  80047b:	e8 d2 11 00 00       	call   801652 <_panic>
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
  800497:	68 d0 24 80 00       	push   $0x8024d0
  80049c:	6a 38                	push   $0x38
  80049e:	68 c5 24 80 00       	push   $0x8024c5
  8004a3:	e8 aa 11 00 00       	call   801652 <_panic>
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
  8004bb:	e8 37 1b 00 00       	call   801ff7 <set_pgfault_handler>
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
  8004d4:	68 e9 24 80 00       	push   $0x8024e9
  8004d9:	68 85 00 00 00       	push   $0x85
  8004de:	68 c5 24 80 00       	push   $0x8024c5
  8004e3:	e8 6a 11 00 00       	call   801652 <_panic>
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
  800590:	68 f7 24 80 00       	push   $0x8024f7
  800595:	6a 55                	push   $0x55
  800597:	68 c5 24 80 00       	push   $0x8024c5
  80059c:	e8 b1 10 00 00       	call   801652 <_panic>
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
  8005d5:	68 f7 24 80 00       	push   $0x8024f7
  8005da:	6a 5c                	push   $0x5c
  8005dc:	68 c5 24 80 00       	push   $0x8024c5
  8005e1:	e8 6c 10 00 00       	call   801652 <_panic>
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
  800603:	68 f7 24 80 00       	push   $0x8024f7
  800608:	6a 60                	push   $0x60
  80060a:	68 c5 24 80 00       	push   $0x8024c5
  80060f:	e8 3e 10 00 00       	call   801652 <_panic>
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
  80062d:	68 f7 24 80 00       	push   $0x8024f7
  800632:	6a 65                	push   $0x65
  800634:	68 c5 24 80 00       	push   $0x8024c5
  800639:	e8 14 10 00 00       	call   801652 <_panic>
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
  80069c:	68 88 25 80 00       	push   $0x802588
  8006a1:	e8 85 10 00 00       	call   80172b <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006a6:	c7 04 24 90 00 80 00 	movl   $0x800090,(%esp)
  8006ad:	e8 c5 fc ff ff       	call   800377 <sys_thread_create>
  8006b2:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006b4:	83 c4 08             	add    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	68 88 25 80 00       	push   $0x802588
  8006bd:	e8 69 10 00 00       	call   80172b <cprintf>
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

008006f1 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	56                   	push   %esi
  8006f5:	53                   	push   %ebx
  8006f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8006fc:	83 ec 04             	sub    $0x4,%esp
  8006ff:	6a 07                	push   $0x7
  800701:	6a 00                	push   $0x0
  800703:	56                   	push   %esi
  800704:	e8 7d fa ff ff       	call   800186 <sys_page_alloc>
	if (r < 0) {
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	79 15                	jns    800725 <queue_append+0x34>
		panic("%e\n", r);
  800710:	50                   	push   %eax
  800711:	68 83 25 80 00       	push   $0x802583
  800716:	68 c4 00 00 00       	push   $0xc4
  80071b:	68 c5 24 80 00       	push   $0x8024c5
  800720:	e8 2d 0f 00 00       	call   801652 <_panic>
	}	
	wt->envid = envid;
  800725:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  80072b:	83 ec 04             	sub    $0x4,%esp
  80072e:	ff 33                	pushl  (%ebx)
  800730:	56                   	push   %esi
  800731:	68 ac 25 80 00       	push   $0x8025ac
  800736:	e8 f0 0f 00 00       	call   80172b <cprintf>
	if (queue->first == NULL) {
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	83 3b 00             	cmpl   $0x0,(%ebx)
  800741:	75 29                	jne    80076c <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  800743:	83 ec 0c             	sub    $0xc,%esp
  800746:	68 0d 25 80 00       	push   $0x80250d
  80074b:	e8 db 0f 00 00       	call   80172b <cprintf>
		queue->first = wt;
  800750:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  800756:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80075d:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800764:	00 00 00 
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	eb 2b                	jmp    800797 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  80076c:	83 ec 0c             	sub    $0xc,%esp
  80076f:	68 27 25 80 00       	push   $0x802527
  800774:	e8 b2 0f 00 00       	call   80172b <cprintf>
		queue->last->next = wt;
  800779:	8b 43 04             	mov    0x4(%ebx),%eax
  80077c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  800783:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80078a:	00 00 00 
		queue->last = wt;
  80078d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  800794:	83 c4 10             	add    $0x10,%esp
	}
}
  800797:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80079a:	5b                   	pop    %ebx
  80079b:	5e                   	pop    %esi
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	53                   	push   %ebx
  8007a2:	83 ec 04             	sub    $0x4,%esp
  8007a5:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8007a8:	8b 02                	mov    (%edx),%eax
  8007aa:	85 c0                	test   %eax,%eax
  8007ac:	75 17                	jne    8007c5 <queue_pop+0x27>
		panic("queue empty!\n");
  8007ae:	83 ec 04             	sub    $0x4,%esp
  8007b1:	68 45 25 80 00       	push   $0x802545
  8007b6:	68 d8 00 00 00       	push   $0xd8
  8007bb:	68 c5 24 80 00       	push   $0x8024c5
  8007c0:	e8 8d 0e 00 00       	call   801652 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8007c5:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c8:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8007ca:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	68 53 25 80 00       	push   $0x802553
  8007d5:	e8 51 0f 00 00       	call   80172b <cprintf>
	return envid;
}
  8007da:	89 d8                	mov    %ebx,%eax
  8007dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    

008007e1 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	83 ec 04             	sub    $0x4,%esp
  8007e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8007eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8007f0:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	74 5a                	je     800851 <mutex_lock+0x70>
  8007f7:	8b 43 04             	mov    0x4(%ebx),%eax
  8007fa:	83 38 00             	cmpl   $0x0,(%eax)
  8007fd:	75 52                	jne    800851 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8007ff:	83 ec 0c             	sub    $0xc,%esp
  800802:	68 d4 25 80 00       	push   $0x8025d4
  800807:	e8 1f 0f 00 00       	call   80172b <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  80080c:	8b 5b 04             	mov    0x4(%ebx),%ebx
  80080f:	e8 34 f9 ff ff       	call   800148 <sys_getenvid>
  800814:	83 c4 08             	add    $0x8,%esp
  800817:	53                   	push   %ebx
  800818:	50                   	push   %eax
  800819:	e8 d3 fe ff ff       	call   8006f1 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80081e:	e8 25 f9 ff ff       	call   800148 <sys_getenvid>
  800823:	83 c4 08             	add    $0x8,%esp
  800826:	6a 04                	push   $0x4
  800828:	50                   	push   %eax
  800829:	e8 1f fa ff ff       	call   80024d <sys_env_set_status>
		if (r < 0) {
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	85 c0                	test   %eax,%eax
  800833:	79 15                	jns    80084a <mutex_lock+0x69>
			panic("%e\n", r);
  800835:	50                   	push   %eax
  800836:	68 83 25 80 00       	push   $0x802583
  80083b:	68 eb 00 00 00       	push   $0xeb
  800840:	68 c5 24 80 00       	push   $0x8024c5
  800845:	e8 08 0e 00 00       	call   801652 <_panic>
		}
		sys_yield();
  80084a:	e8 18 f9 ff ff       	call   800167 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80084f:	eb 18                	jmp    800869 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  800851:	83 ec 0c             	sub    $0xc,%esp
  800854:	68 f4 25 80 00       	push   $0x8025f4
  800859:	e8 cd 0e 00 00       	call   80172b <cprintf>
	mtx->owner = sys_getenvid();}
  80085e:	e8 e5 f8 ff ff       	call   800148 <sys_getenvid>
  800863:	89 43 08             	mov    %eax,0x8(%ebx)
  800866:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  800869:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	53                   	push   %ebx
  800872:	83 ec 04             	sub    $0x4,%esp
  800875:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800878:	b8 00 00 00 00       	mov    $0x0,%eax
  80087d:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  800880:	8b 43 04             	mov    0x4(%ebx),%eax
  800883:	83 38 00             	cmpl   $0x0,(%eax)
  800886:	74 33                	je     8008bb <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  800888:	83 ec 0c             	sub    $0xc,%esp
  80088b:	50                   	push   %eax
  80088c:	e8 0d ff ff ff       	call   80079e <queue_pop>
  800891:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  800894:	83 c4 08             	add    $0x8,%esp
  800897:	6a 02                	push   $0x2
  800899:	50                   	push   %eax
  80089a:	e8 ae f9 ff ff       	call   80024d <sys_env_set_status>
		if (r < 0) {
  80089f:	83 c4 10             	add    $0x10,%esp
  8008a2:	85 c0                	test   %eax,%eax
  8008a4:	79 15                	jns    8008bb <mutex_unlock+0x4d>
			panic("%e\n", r);
  8008a6:	50                   	push   %eax
  8008a7:	68 83 25 80 00       	push   $0x802583
  8008ac:	68 00 01 00 00       	push   $0x100
  8008b1:	68 c5 24 80 00       	push   $0x8024c5
  8008b6:	e8 97 0d 00 00       	call   801652 <_panic>
		}
	}

	asm volatile("pause");
  8008bb:	f3 90                	pause  
	//sys_yield();
}
  8008bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    

008008c2 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	83 ec 04             	sub    $0x4,%esp
  8008c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8008cc:	e8 77 f8 ff ff       	call   800148 <sys_getenvid>
  8008d1:	83 ec 04             	sub    $0x4,%esp
  8008d4:	6a 07                	push   $0x7
  8008d6:	53                   	push   %ebx
  8008d7:	50                   	push   %eax
  8008d8:	e8 a9 f8 ff ff       	call   800186 <sys_page_alloc>
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	79 15                	jns    8008f9 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8008e4:	50                   	push   %eax
  8008e5:	68 6e 25 80 00       	push   $0x80256e
  8008ea:	68 0d 01 00 00       	push   $0x10d
  8008ef:	68 c5 24 80 00       	push   $0x8024c5
  8008f4:	e8 59 0d 00 00       	call   801652 <_panic>
	}	
	mtx->locked = 0;
  8008f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8008ff:	8b 43 04             	mov    0x4(%ebx),%eax
  800902:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  800908:	8b 43 04             	mov    0x4(%ebx),%eax
  80090b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  800912:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  800919:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  800924:	e8 1f f8 ff ff       	call   800148 <sys_getenvid>
  800929:	83 ec 08             	sub    $0x8,%esp
  80092c:	ff 75 08             	pushl  0x8(%ebp)
  80092f:	50                   	push   %eax
  800930:	e8 d6 f8 ff ff       	call   80020b <sys_page_unmap>
	if (r < 0) {
  800935:	83 c4 10             	add    $0x10,%esp
  800938:	85 c0                	test   %eax,%eax
  80093a:	79 15                	jns    800951 <mutex_destroy+0x33>
		panic("%e\n", r);
  80093c:	50                   	push   %eax
  80093d:	68 83 25 80 00       	push   $0x802583
  800942:	68 1a 01 00 00       	push   $0x11a
  800947:	68 c5 24 80 00       	push   $0x8024c5
  80094c:	e8 01 0d 00 00       	call   801652 <_panic>
	}
}
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	05 00 00 00 30       	add    $0x30000000,%eax
  80095e:	c1 e8 0c             	shr    $0xc,%eax
}
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	05 00 00 00 30       	add    $0x30000000,%eax
  80096e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800973:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800980:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800985:	89 c2                	mov    %eax,%edx
  800987:	c1 ea 16             	shr    $0x16,%edx
  80098a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800991:	f6 c2 01             	test   $0x1,%dl
  800994:	74 11                	je     8009a7 <fd_alloc+0x2d>
  800996:	89 c2                	mov    %eax,%edx
  800998:	c1 ea 0c             	shr    $0xc,%edx
  80099b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8009a2:	f6 c2 01             	test   $0x1,%dl
  8009a5:	75 09                	jne    8009b0 <fd_alloc+0x36>
			*fd_store = fd;
  8009a7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ae:	eb 17                	jmp    8009c7 <fd_alloc+0x4d>
  8009b0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8009b5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8009ba:	75 c9                	jne    800985 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8009bc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8009c2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8009cf:	83 f8 1f             	cmp    $0x1f,%eax
  8009d2:	77 36                	ja     800a0a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8009d4:	c1 e0 0c             	shl    $0xc,%eax
  8009d7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8009dc:	89 c2                	mov    %eax,%edx
  8009de:	c1 ea 16             	shr    $0x16,%edx
  8009e1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8009e8:	f6 c2 01             	test   $0x1,%dl
  8009eb:	74 24                	je     800a11 <fd_lookup+0x48>
  8009ed:	89 c2                	mov    %eax,%edx
  8009ef:	c1 ea 0c             	shr    $0xc,%edx
  8009f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8009f9:	f6 c2 01             	test   $0x1,%dl
  8009fc:	74 1a                	je     800a18 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8009fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a01:	89 02                	mov    %eax,(%edx)
	return 0;
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
  800a08:	eb 13                	jmp    800a1d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a0f:	eb 0c                	jmp    800a1d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a16:	eb 05                	jmp    800a1d <fd_lookup+0x54>
  800a18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	83 ec 08             	sub    $0x8,%esp
  800a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a28:	ba 90 26 80 00       	mov    $0x802690,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800a2d:	eb 13                	jmp    800a42 <dev_lookup+0x23>
  800a2f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800a32:	39 08                	cmp    %ecx,(%eax)
  800a34:	75 0c                	jne    800a42 <dev_lookup+0x23>
			*dev = devtab[i];
  800a36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a39:	89 01                	mov    %eax,(%ecx)
			return 0;
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a40:	eb 31                	jmp    800a73 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800a42:	8b 02                	mov    (%edx),%eax
  800a44:	85 c0                	test   %eax,%eax
  800a46:	75 e7                	jne    800a2f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800a48:	a1 04 40 80 00       	mov    0x804004,%eax
  800a4d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a53:	83 ec 04             	sub    $0x4,%esp
  800a56:	51                   	push   %ecx
  800a57:	50                   	push   %eax
  800a58:	68 14 26 80 00       	push   $0x802614
  800a5d:	e8 c9 0c 00 00       	call   80172b <cprintf>
	*dev = 0;
  800a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a65:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800a6b:	83 c4 10             	add    $0x10,%esp
  800a6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a73:	c9                   	leave  
  800a74:	c3                   	ret    

00800a75 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	83 ec 10             	sub    $0x10,%esp
  800a7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a86:	50                   	push   %eax
  800a87:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a8d:	c1 e8 0c             	shr    $0xc,%eax
  800a90:	50                   	push   %eax
  800a91:	e8 33 ff ff ff       	call   8009c9 <fd_lookup>
  800a96:	83 c4 08             	add    $0x8,%esp
  800a99:	85 c0                	test   %eax,%eax
  800a9b:	78 05                	js     800aa2 <fd_close+0x2d>
	    || fd != fd2)
  800a9d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800aa0:	74 0c                	je     800aae <fd_close+0x39>
		return (must_exist ? r : 0);
  800aa2:	84 db                	test   %bl,%bl
  800aa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa9:	0f 44 c2             	cmove  %edx,%eax
  800aac:	eb 41                	jmp    800aef <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800aae:	83 ec 08             	sub    $0x8,%esp
  800ab1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ab4:	50                   	push   %eax
  800ab5:	ff 36                	pushl  (%esi)
  800ab7:	e8 63 ff ff ff       	call   800a1f <dev_lookup>
  800abc:	89 c3                	mov    %eax,%ebx
  800abe:	83 c4 10             	add    $0x10,%esp
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	78 1a                	js     800adf <fd_close+0x6a>
		if (dev->dev_close)
  800ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800acb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ad0:	85 c0                	test   %eax,%eax
  800ad2:	74 0b                	je     800adf <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ad4:	83 ec 0c             	sub    $0xc,%esp
  800ad7:	56                   	push   %esi
  800ad8:	ff d0                	call   *%eax
  800ada:	89 c3                	mov    %eax,%ebx
  800adc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800adf:	83 ec 08             	sub    $0x8,%esp
  800ae2:	56                   	push   %esi
  800ae3:	6a 00                	push   $0x0
  800ae5:	e8 21 f7 ff ff       	call   80020b <sys_page_unmap>
	return r;
  800aea:	83 c4 10             	add    $0x10,%esp
  800aed:	89 d8                	mov    %ebx,%eax
}
  800aef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800afc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aff:	50                   	push   %eax
  800b00:	ff 75 08             	pushl  0x8(%ebp)
  800b03:	e8 c1 fe ff ff       	call   8009c9 <fd_lookup>
  800b08:	83 c4 08             	add    $0x8,%esp
  800b0b:	85 c0                	test   %eax,%eax
  800b0d:	78 10                	js     800b1f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800b0f:	83 ec 08             	sub    $0x8,%esp
  800b12:	6a 01                	push   $0x1
  800b14:	ff 75 f4             	pushl  -0xc(%ebp)
  800b17:	e8 59 ff ff ff       	call   800a75 <fd_close>
  800b1c:	83 c4 10             	add    $0x10,%esp
}
  800b1f:	c9                   	leave  
  800b20:	c3                   	ret    

00800b21 <close_all>:

void
close_all(void)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	53                   	push   %ebx
  800b25:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800b28:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800b2d:	83 ec 0c             	sub    $0xc,%esp
  800b30:	53                   	push   %ebx
  800b31:	e8 c0 ff ff ff       	call   800af6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800b36:	83 c3 01             	add    $0x1,%ebx
  800b39:	83 c4 10             	add    $0x10,%esp
  800b3c:	83 fb 20             	cmp    $0x20,%ebx
  800b3f:	75 ec                	jne    800b2d <close_all+0xc>
		close(i);
}
  800b41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b44:	c9                   	leave  
  800b45:	c3                   	ret    

00800b46 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
  800b4c:	83 ec 2c             	sub    $0x2c,%esp
  800b4f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800b52:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800b55:	50                   	push   %eax
  800b56:	ff 75 08             	pushl  0x8(%ebp)
  800b59:	e8 6b fe ff ff       	call   8009c9 <fd_lookup>
  800b5e:	83 c4 08             	add    $0x8,%esp
  800b61:	85 c0                	test   %eax,%eax
  800b63:	0f 88 c1 00 00 00    	js     800c2a <dup+0xe4>
		return r;
	close(newfdnum);
  800b69:	83 ec 0c             	sub    $0xc,%esp
  800b6c:	56                   	push   %esi
  800b6d:	e8 84 ff ff ff       	call   800af6 <close>

	newfd = INDEX2FD(newfdnum);
  800b72:	89 f3                	mov    %esi,%ebx
  800b74:	c1 e3 0c             	shl    $0xc,%ebx
  800b77:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b7d:	83 c4 04             	add    $0x4,%esp
  800b80:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b83:	e8 db fd ff ff       	call   800963 <fd2data>
  800b88:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b8a:	89 1c 24             	mov    %ebx,(%esp)
  800b8d:	e8 d1 fd ff ff       	call   800963 <fd2data>
  800b92:	83 c4 10             	add    $0x10,%esp
  800b95:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b98:	89 f8                	mov    %edi,%eax
  800b9a:	c1 e8 16             	shr    $0x16,%eax
  800b9d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ba4:	a8 01                	test   $0x1,%al
  800ba6:	74 37                	je     800bdf <dup+0x99>
  800ba8:	89 f8                	mov    %edi,%eax
  800baa:	c1 e8 0c             	shr    $0xc,%eax
  800bad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800bb4:	f6 c2 01             	test   $0x1,%dl
  800bb7:	74 26                	je     800bdf <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800bb9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	25 07 0e 00 00       	and    $0xe07,%eax
  800bc8:	50                   	push   %eax
  800bc9:	ff 75 d4             	pushl  -0x2c(%ebp)
  800bcc:	6a 00                	push   $0x0
  800bce:	57                   	push   %edi
  800bcf:	6a 00                	push   $0x0
  800bd1:	e8 f3 f5 ff ff       	call   8001c9 <sys_page_map>
  800bd6:	89 c7                	mov    %eax,%edi
  800bd8:	83 c4 20             	add    $0x20,%esp
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	78 2e                	js     800c0d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800bdf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800be2:	89 d0                	mov    %edx,%eax
  800be4:	c1 e8 0c             	shr    $0xc,%eax
  800be7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	25 07 0e 00 00       	and    $0xe07,%eax
  800bf6:	50                   	push   %eax
  800bf7:	53                   	push   %ebx
  800bf8:	6a 00                	push   $0x0
  800bfa:	52                   	push   %edx
  800bfb:	6a 00                	push   $0x0
  800bfd:	e8 c7 f5 ff ff       	call   8001c9 <sys_page_map>
  800c02:	89 c7                	mov    %eax,%edi
  800c04:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800c07:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800c09:	85 ff                	test   %edi,%edi
  800c0b:	79 1d                	jns    800c2a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800c0d:	83 ec 08             	sub    $0x8,%esp
  800c10:	53                   	push   %ebx
  800c11:	6a 00                	push   $0x0
  800c13:	e8 f3 f5 ff ff       	call   80020b <sys_page_unmap>
	sys_page_unmap(0, nva);
  800c18:	83 c4 08             	add    $0x8,%esp
  800c1b:	ff 75 d4             	pushl  -0x2c(%ebp)
  800c1e:	6a 00                	push   $0x0
  800c20:	e8 e6 f5 ff ff       	call   80020b <sys_page_unmap>
	return r;
  800c25:	83 c4 10             	add    $0x10,%esp
  800c28:	89 f8                	mov    %edi,%eax
}
  800c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	53                   	push   %ebx
  800c36:	83 ec 14             	sub    $0x14,%esp
  800c39:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c3c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c3f:	50                   	push   %eax
  800c40:	53                   	push   %ebx
  800c41:	e8 83 fd ff ff       	call   8009c9 <fd_lookup>
  800c46:	83 c4 08             	add    $0x8,%esp
  800c49:	89 c2                	mov    %eax,%edx
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	78 70                	js     800cbf <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c4f:	83 ec 08             	sub    $0x8,%esp
  800c52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c55:	50                   	push   %eax
  800c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c59:	ff 30                	pushl  (%eax)
  800c5b:	e8 bf fd ff ff       	call   800a1f <dev_lookup>
  800c60:	83 c4 10             	add    $0x10,%esp
  800c63:	85 c0                	test   %eax,%eax
  800c65:	78 4f                	js     800cb6 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800c67:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c6a:	8b 42 08             	mov    0x8(%edx),%eax
  800c6d:	83 e0 03             	and    $0x3,%eax
  800c70:	83 f8 01             	cmp    $0x1,%eax
  800c73:	75 24                	jne    800c99 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800c75:	a1 04 40 80 00       	mov    0x804004,%eax
  800c7a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800c80:	83 ec 04             	sub    $0x4,%esp
  800c83:	53                   	push   %ebx
  800c84:	50                   	push   %eax
  800c85:	68 55 26 80 00       	push   $0x802655
  800c8a:	e8 9c 0a 00 00       	call   80172b <cprintf>
		return -E_INVAL;
  800c8f:	83 c4 10             	add    $0x10,%esp
  800c92:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c97:	eb 26                	jmp    800cbf <read+0x8d>
	}
	if (!dev->dev_read)
  800c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9c:	8b 40 08             	mov    0x8(%eax),%eax
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	74 17                	je     800cba <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800ca3:	83 ec 04             	sub    $0x4,%esp
  800ca6:	ff 75 10             	pushl  0x10(%ebp)
  800ca9:	ff 75 0c             	pushl  0xc(%ebp)
  800cac:	52                   	push   %edx
  800cad:	ff d0                	call   *%eax
  800caf:	89 c2                	mov    %eax,%edx
  800cb1:	83 c4 10             	add    $0x10,%esp
  800cb4:	eb 09                	jmp    800cbf <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cb6:	89 c2                	mov    %eax,%edx
  800cb8:	eb 05                	jmp    800cbf <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800cba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800cbf:	89 d0                	mov    %edx,%eax
  800cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cc4:	c9                   	leave  
  800cc5:	c3                   	ret    

00800cc6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 0c             	sub    $0xc,%esp
  800ccf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cd2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	eb 21                	jmp    800cfd <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800cdc:	83 ec 04             	sub    $0x4,%esp
  800cdf:	89 f0                	mov    %esi,%eax
  800ce1:	29 d8                	sub    %ebx,%eax
  800ce3:	50                   	push   %eax
  800ce4:	89 d8                	mov    %ebx,%eax
  800ce6:	03 45 0c             	add    0xc(%ebp),%eax
  800ce9:	50                   	push   %eax
  800cea:	57                   	push   %edi
  800ceb:	e8 42 ff ff ff       	call   800c32 <read>
		if (m < 0)
  800cf0:	83 c4 10             	add    $0x10,%esp
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	78 10                	js     800d07 <readn+0x41>
			return m;
		if (m == 0)
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	74 0a                	je     800d05 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800cfb:	01 c3                	add    %eax,%ebx
  800cfd:	39 f3                	cmp    %esi,%ebx
  800cff:	72 db                	jb     800cdc <readn+0x16>
  800d01:	89 d8                	mov    %ebx,%eax
  800d03:	eb 02                	jmp    800d07 <readn+0x41>
  800d05:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	53                   	push   %ebx
  800d13:	83 ec 14             	sub    $0x14,%esp
  800d16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d19:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d1c:	50                   	push   %eax
  800d1d:	53                   	push   %ebx
  800d1e:	e8 a6 fc ff ff       	call   8009c9 <fd_lookup>
  800d23:	83 c4 08             	add    $0x8,%esp
  800d26:	89 c2                	mov    %eax,%edx
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	78 6b                	js     800d97 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d2c:	83 ec 08             	sub    $0x8,%esp
  800d2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d32:	50                   	push   %eax
  800d33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d36:	ff 30                	pushl  (%eax)
  800d38:	e8 e2 fc ff ff       	call   800a1f <dev_lookup>
  800d3d:	83 c4 10             	add    $0x10,%esp
  800d40:	85 c0                	test   %eax,%eax
  800d42:	78 4a                	js     800d8e <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d47:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d4b:	75 24                	jne    800d71 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800d4d:	a1 04 40 80 00       	mov    0x804004,%eax
  800d52:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800d58:	83 ec 04             	sub    $0x4,%esp
  800d5b:	53                   	push   %ebx
  800d5c:	50                   	push   %eax
  800d5d:	68 71 26 80 00       	push   $0x802671
  800d62:	e8 c4 09 00 00       	call   80172b <cprintf>
		return -E_INVAL;
  800d67:	83 c4 10             	add    $0x10,%esp
  800d6a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d6f:	eb 26                	jmp    800d97 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800d71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d74:	8b 52 0c             	mov    0xc(%edx),%edx
  800d77:	85 d2                	test   %edx,%edx
  800d79:	74 17                	je     800d92 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d7b:	83 ec 04             	sub    $0x4,%esp
  800d7e:	ff 75 10             	pushl  0x10(%ebp)
  800d81:	ff 75 0c             	pushl  0xc(%ebp)
  800d84:	50                   	push   %eax
  800d85:	ff d2                	call   *%edx
  800d87:	89 c2                	mov    %eax,%edx
  800d89:	83 c4 10             	add    $0x10,%esp
  800d8c:	eb 09                	jmp    800d97 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d8e:	89 c2                	mov    %eax,%edx
  800d90:	eb 05                	jmp    800d97 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d92:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d97:	89 d0                	mov    %edx,%eax
  800d99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d9c:	c9                   	leave  
  800d9d:	c3                   	ret    

00800d9e <seek>:

int
seek(int fdnum, off_t offset)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800da4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800da7:	50                   	push   %eax
  800da8:	ff 75 08             	pushl  0x8(%ebp)
  800dab:	e8 19 fc ff ff       	call   8009c9 <fd_lookup>
  800db0:	83 c4 08             	add    $0x8,%esp
  800db3:	85 c0                	test   %eax,%eax
  800db5:	78 0e                	js     800dc5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800db7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800dba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dbd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800dc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc5:	c9                   	leave  
  800dc6:	c3                   	ret    

00800dc7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	53                   	push   %ebx
  800dcb:	83 ec 14             	sub    $0x14,%esp
  800dce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dd1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dd4:	50                   	push   %eax
  800dd5:	53                   	push   %ebx
  800dd6:	e8 ee fb ff ff       	call   8009c9 <fd_lookup>
  800ddb:	83 c4 08             	add    $0x8,%esp
  800dde:	89 c2                	mov    %eax,%edx
  800de0:	85 c0                	test   %eax,%eax
  800de2:	78 68                	js     800e4c <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800de4:	83 ec 08             	sub    $0x8,%esp
  800de7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dea:	50                   	push   %eax
  800deb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dee:	ff 30                	pushl  (%eax)
  800df0:	e8 2a fc ff ff       	call   800a1f <dev_lookup>
  800df5:	83 c4 10             	add    $0x10,%esp
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	78 47                	js     800e43 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800dfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dff:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800e03:	75 24                	jne    800e29 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800e05:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800e0a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800e10:	83 ec 04             	sub    $0x4,%esp
  800e13:	53                   	push   %ebx
  800e14:	50                   	push   %eax
  800e15:	68 34 26 80 00       	push   $0x802634
  800e1a:	e8 0c 09 00 00       	call   80172b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800e1f:	83 c4 10             	add    $0x10,%esp
  800e22:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800e27:	eb 23                	jmp    800e4c <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800e29:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e2c:	8b 52 18             	mov    0x18(%edx),%edx
  800e2f:	85 d2                	test   %edx,%edx
  800e31:	74 14                	je     800e47 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800e33:	83 ec 08             	sub    $0x8,%esp
  800e36:	ff 75 0c             	pushl  0xc(%ebp)
  800e39:	50                   	push   %eax
  800e3a:	ff d2                	call   *%edx
  800e3c:	89 c2                	mov    %eax,%edx
  800e3e:	83 c4 10             	add    $0x10,%esp
  800e41:	eb 09                	jmp    800e4c <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e43:	89 c2                	mov    %eax,%edx
  800e45:	eb 05                	jmp    800e4c <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800e47:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800e4c:	89 d0                	mov    %edx,%eax
  800e4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e51:	c9                   	leave  
  800e52:	c3                   	ret    

00800e53 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	53                   	push   %ebx
  800e57:	83 ec 14             	sub    $0x14,%esp
  800e5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e5d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e60:	50                   	push   %eax
  800e61:	ff 75 08             	pushl  0x8(%ebp)
  800e64:	e8 60 fb ff ff       	call   8009c9 <fd_lookup>
  800e69:	83 c4 08             	add    $0x8,%esp
  800e6c:	89 c2                	mov    %eax,%edx
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	78 58                	js     800eca <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e72:	83 ec 08             	sub    $0x8,%esp
  800e75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e78:	50                   	push   %eax
  800e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e7c:	ff 30                	pushl  (%eax)
  800e7e:	e8 9c fb ff ff       	call   800a1f <dev_lookup>
  800e83:	83 c4 10             	add    $0x10,%esp
  800e86:	85 c0                	test   %eax,%eax
  800e88:	78 37                	js     800ec1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e8d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e91:	74 32                	je     800ec5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e93:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e96:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e9d:	00 00 00 
	stat->st_isdir = 0;
  800ea0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ea7:	00 00 00 
	stat->st_dev = dev;
  800eaa:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800eb0:	83 ec 08             	sub    $0x8,%esp
  800eb3:	53                   	push   %ebx
  800eb4:	ff 75 f0             	pushl  -0x10(%ebp)
  800eb7:	ff 50 14             	call   *0x14(%eax)
  800eba:	89 c2                	mov    %eax,%edx
  800ebc:	83 c4 10             	add    $0x10,%esp
  800ebf:	eb 09                	jmp    800eca <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ec1:	89 c2                	mov    %eax,%edx
  800ec3:	eb 05                	jmp    800eca <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800ec5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800eca:	89 d0                	mov    %edx,%eax
  800ecc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    

00800ed1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800ed6:	83 ec 08             	sub    $0x8,%esp
  800ed9:	6a 00                	push   $0x0
  800edb:	ff 75 08             	pushl  0x8(%ebp)
  800ede:	e8 e3 01 00 00       	call   8010c6 <open>
  800ee3:	89 c3                	mov    %eax,%ebx
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	78 1b                	js     800f07 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800eec:	83 ec 08             	sub    $0x8,%esp
  800eef:	ff 75 0c             	pushl  0xc(%ebp)
  800ef2:	50                   	push   %eax
  800ef3:	e8 5b ff ff ff       	call   800e53 <fstat>
  800ef8:	89 c6                	mov    %eax,%esi
	close(fd);
  800efa:	89 1c 24             	mov    %ebx,(%esp)
  800efd:	e8 f4 fb ff ff       	call   800af6 <close>
	return r;
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	89 f0                	mov    %esi,%eax
}
  800f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	56                   	push   %esi
  800f12:	53                   	push   %ebx
  800f13:	89 c6                	mov    %eax,%esi
  800f15:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800f17:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800f1e:	75 12                	jne    800f32 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800f20:	83 ec 0c             	sub    $0xc,%esp
  800f23:	6a 01                	push   $0x1
  800f25:	e8 39 12 00 00       	call   802163 <ipc_find_env>
  800f2a:	a3 00 40 80 00       	mov    %eax,0x804000
  800f2f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800f32:	6a 07                	push   $0x7
  800f34:	68 00 50 80 00       	push   $0x805000
  800f39:	56                   	push   %esi
  800f3a:	ff 35 00 40 80 00    	pushl  0x804000
  800f40:	e8 bc 11 00 00       	call   802101 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800f45:	83 c4 0c             	add    $0xc,%esp
  800f48:	6a 00                	push   $0x0
  800f4a:	53                   	push   %ebx
  800f4b:	6a 00                	push   $0x0
  800f4d:	e8 34 11 00 00       	call   802086 <ipc_recv>
}
  800f52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f62:	8b 40 0c             	mov    0xc(%eax),%eax
  800f65:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800f6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800f72:	ba 00 00 00 00       	mov    $0x0,%edx
  800f77:	b8 02 00 00 00       	mov    $0x2,%eax
  800f7c:	e8 8d ff ff ff       	call   800f0e <fsipc>
}
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f89:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8c:	8b 40 0c             	mov    0xc(%eax),%eax
  800f8f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f94:	ba 00 00 00 00       	mov    $0x0,%edx
  800f99:	b8 06 00 00 00       	mov    $0x6,%eax
  800f9e:	e8 6b ff ff ff       	call   800f0e <fsipc>
}
  800fa3:	c9                   	leave  
  800fa4:	c3                   	ret    

00800fa5 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	53                   	push   %ebx
  800fa9:	83 ec 04             	sub    $0x4,%esp
  800fac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800faf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb2:	8b 40 0c             	mov    0xc(%eax),%eax
  800fb5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800fba:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbf:	b8 05 00 00 00       	mov    $0x5,%eax
  800fc4:	e8 45 ff ff ff       	call   800f0e <fsipc>
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	78 2c                	js     800ff9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800fcd:	83 ec 08             	sub    $0x8,%esp
  800fd0:	68 00 50 80 00       	push   $0x805000
  800fd5:	53                   	push   %ebx
  800fd6:	e8 d5 0c 00 00       	call   801cb0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800fdb:	a1 80 50 80 00       	mov    0x805080,%eax
  800fe0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800fe6:	a1 84 50 80 00       	mov    0x805084,%eax
  800feb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ff9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ffc:	c9                   	leave  
  800ffd:	c3                   	ret    

00800ffe <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	83 ec 0c             	sub    $0xc,%esp
  801004:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801007:	8b 55 08             	mov    0x8(%ebp),%edx
  80100a:	8b 52 0c             	mov    0xc(%edx),%edx
  80100d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801013:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801018:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80101d:	0f 47 c2             	cmova  %edx,%eax
  801020:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801025:	50                   	push   %eax
  801026:	ff 75 0c             	pushl  0xc(%ebp)
  801029:	68 08 50 80 00       	push   $0x805008
  80102e:	e8 0f 0e 00 00       	call   801e42 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801033:	ba 00 00 00 00       	mov    $0x0,%edx
  801038:	b8 04 00 00 00       	mov    $0x4,%eax
  80103d:	e8 cc fe ff ff       	call   800f0e <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
  801049:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80104c:	8b 45 08             	mov    0x8(%ebp),%eax
  80104f:	8b 40 0c             	mov    0xc(%eax),%eax
  801052:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801057:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80105d:	ba 00 00 00 00       	mov    $0x0,%edx
  801062:	b8 03 00 00 00       	mov    $0x3,%eax
  801067:	e8 a2 fe ff ff       	call   800f0e <fsipc>
  80106c:	89 c3                	mov    %eax,%ebx
  80106e:	85 c0                	test   %eax,%eax
  801070:	78 4b                	js     8010bd <devfile_read+0x79>
		return r;
	assert(r <= n);
  801072:	39 c6                	cmp    %eax,%esi
  801074:	73 16                	jae    80108c <devfile_read+0x48>
  801076:	68 a0 26 80 00       	push   $0x8026a0
  80107b:	68 a7 26 80 00       	push   $0x8026a7
  801080:	6a 7c                	push   $0x7c
  801082:	68 bc 26 80 00       	push   $0x8026bc
  801087:	e8 c6 05 00 00       	call   801652 <_panic>
	assert(r <= PGSIZE);
  80108c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801091:	7e 16                	jle    8010a9 <devfile_read+0x65>
  801093:	68 c7 26 80 00       	push   $0x8026c7
  801098:	68 a7 26 80 00       	push   $0x8026a7
  80109d:	6a 7d                	push   $0x7d
  80109f:	68 bc 26 80 00       	push   $0x8026bc
  8010a4:	e8 a9 05 00 00       	call   801652 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8010a9:	83 ec 04             	sub    $0x4,%esp
  8010ac:	50                   	push   %eax
  8010ad:	68 00 50 80 00       	push   $0x805000
  8010b2:	ff 75 0c             	pushl  0xc(%ebp)
  8010b5:	e8 88 0d 00 00       	call   801e42 <memmove>
	return r;
  8010ba:	83 c4 10             	add    $0x10,%esp
}
  8010bd:	89 d8                	mov    %ebx,%eax
  8010bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010c2:	5b                   	pop    %ebx
  8010c3:	5e                   	pop    %esi
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    

008010c6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	53                   	push   %ebx
  8010ca:	83 ec 20             	sub    $0x20,%esp
  8010cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8010d0:	53                   	push   %ebx
  8010d1:	e8 a1 0b 00 00       	call   801c77 <strlen>
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8010de:	7f 67                	jg     801147 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e6:	50                   	push   %eax
  8010e7:	e8 8e f8 ff ff       	call   80097a <fd_alloc>
  8010ec:	83 c4 10             	add    $0x10,%esp
		return r;
  8010ef:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	78 57                	js     80114c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8010f5:	83 ec 08             	sub    $0x8,%esp
  8010f8:	53                   	push   %ebx
  8010f9:	68 00 50 80 00       	push   $0x805000
  8010fe:	e8 ad 0b 00 00       	call   801cb0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801103:	8b 45 0c             	mov    0xc(%ebp),%eax
  801106:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80110b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80110e:	b8 01 00 00 00       	mov    $0x1,%eax
  801113:	e8 f6 fd ff ff       	call   800f0e <fsipc>
  801118:	89 c3                	mov    %eax,%ebx
  80111a:	83 c4 10             	add    $0x10,%esp
  80111d:	85 c0                	test   %eax,%eax
  80111f:	79 14                	jns    801135 <open+0x6f>
		fd_close(fd, 0);
  801121:	83 ec 08             	sub    $0x8,%esp
  801124:	6a 00                	push   $0x0
  801126:	ff 75 f4             	pushl  -0xc(%ebp)
  801129:	e8 47 f9 ff ff       	call   800a75 <fd_close>
		return r;
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	89 da                	mov    %ebx,%edx
  801133:	eb 17                	jmp    80114c <open+0x86>
	}

	return fd2num(fd);
  801135:	83 ec 0c             	sub    $0xc,%esp
  801138:	ff 75 f4             	pushl  -0xc(%ebp)
  80113b:	e8 13 f8 ff ff       	call   800953 <fd2num>
  801140:	89 c2                	mov    %eax,%edx
  801142:	83 c4 10             	add    $0x10,%esp
  801145:	eb 05                	jmp    80114c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801147:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80114c:	89 d0                	mov    %edx,%eax
  80114e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801159:	ba 00 00 00 00       	mov    $0x0,%edx
  80115e:	b8 08 00 00 00       	mov    $0x8,%eax
  801163:	e8 a6 fd ff ff       	call   800f0e <fsipc>
}
  801168:	c9                   	leave  
  801169:	c3                   	ret    

0080116a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	56                   	push   %esi
  80116e:	53                   	push   %ebx
  80116f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801172:	83 ec 0c             	sub    $0xc,%esp
  801175:	ff 75 08             	pushl  0x8(%ebp)
  801178:	e8 e6 f7 ff ff       	call   800963 <fd2data>
  80117d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80117f:	83 c4 08             	add    $0x8,%esp
  801182:	68 d3 26 80 00       	push   $0x8026d3
  801187:	53                   	push   %ebx
  801188:	e8 23 0b 00 00       	call   801cb0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80118d:	8b 46 04             	mov    0x4(%esi),%eax
  801190:	2b 06                	sub    (%esi),%eax
  801192:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801198:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80119f:	00 00 00 
	stat->st_dev = &devpipe;
  8011a2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8011a9:	30 80 00 
	return 0;
}
  8011ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	53                   	push   %ebx
  8011bc:	83 ec 0c             	sub    $0xc,%esp
  8011bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8011c2:	53                   	push   %ebx
  8011c3:	6a 00                	push   $0x0
  8011c5:	e8 41 f0 ff ff       	call   80020b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8011ca:	89 1c 24             	mov    %ebx,(%esp)
  8011cd:	e8 91 f7 ff ff       	call   800963 <fd2data>
  8011d2:	83 c4 08             	add    $0x8,%esp
  8011d5:	50                   	push   %eax
  8011d6:	6a 00                	push   $0x0
  8011d8:	e8 2e f0 ff ff       	call   80020b <sys_page_unmap>
}
  8011dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e0:	c9                   	leave  
  8011e1:	c3                   	ret    

008011e2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	57                   	push   %edi
  8011e6:	56                   	push   %esi
  8011e7:	53                   	push   %ebx
  8011e8:	83 ec 1c             	sub    $0x1c,%esp
  8011eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011ee:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8011f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f5:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8011fb:	83 ec 0c             	sub    $0xc,%esp
  8011fe:	ff 75 e0             	pushl  -0x20(%ebp)
  801201:	e8 a2 0f 00 00       	call   8021a8 <pageref>
  801206:	89 c3                	mov    %eax,%ebx
  801208:	89 3c 24             	mov    %edi,(%esp)
  80120b:	e8 98 0f 00 00       	call   8021a8 <pageref>
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	39 c3                	cmp    %eax,%ebx
  801215:	0f 94 c1             	sete   %cl
  801218:	0f b6 c9             	movzbl %cl,%ecx
  80121b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80121e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801224:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  80122a:	39 ce                	cmp    %ecx,%esi
  80122c:	74 1e                	je     80124c <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  80122e:	39 c3                	cmp    %eax,%ebx
  801230:	75 be                	jne    8011f0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801232:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801238:	ff 75 e4             	pushl  -0x1c(%ebp)
  80123b:	50                   	push   %eax
  80123c:	56                   	push   %esi
  80123d:	68 da 26 80 00       	push   $0x8026da
  801242:	e8 e4 04 00 00       	call   80172b <cprintf>
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	eb a4                	jmp    8011f0 <_pipeisclosed+0xe>
	}
}
  80124c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80124f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801252:	5b                   	pop    %ebx
  801253:	5e                   	pop    %esi
  801254:	5f                   	pop    %edi
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	57                   	push   %edi
  80125b:	56                   	push   %esi
  80125c:	53                   	push   %ebx
  80125d:	83 ec 28             	sub    $0x28,%esp
  801260:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801263:	56                   	push   %esi
  801264:	e8 fa f6 ff ff       	call   800963 <fd2data>
  801269:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	bf 00 00 00 00       	mov    $0x0,%edi
  801273:	eb 4b                	jmp    8012c0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801275:	89 da                	mov    %ebx,%edx
  801277:	89 f0                	mov    %esi,%eax
  801279:	e8 64 ff ff ff       	call   8011e2 <_pipeisclosed>
  80127e:	85 c0                	test   %eax,%eax
  801280:	75 48                	jne    8012ca <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801282:	e8 e0 ee ff ff       	call   800167 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801287:	8b 43 04             	mov    0x4(%ebx),%eax
  80128a:	8b 0b                	mov    (%ebx),%ecx
  80128c:	8d 51 20             	lea    0x20(%ecx),%edx
  80128f:	39 d0                	cmp    %edx,%eax
  801291:	73 e2                	jae    801275 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801296:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80129a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80129d:	89 c2                	mov    %eax,%edx
  80129f:	c1 fa 1f             	sar    $0x1f,%edx
  8012a2:	89 d1                	mov    %edx,%ecx
  8012a4:	c1 e9 1b             	shr    $0x1b,%ecx
  8012a7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8012aa:	83 e2 1f             	and    $0x1f,%edx
  8012ad:	29 ca                	sub    %ecx,%edx
  8012af:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8012b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8012b7:	83 c0 01             	add    $0x1,%eax
  8012ba:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012bd:	83 c7 01             	add    $0x1,%edi
  8012c0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8012c3:	75 c2                	jne    801287 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8012c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8012c8:	eb 05                	jmp    8012cf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012ca:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8012cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d2:	5b                   	pop    %ebx
  8012d3:	5e                   	pop    %esi
  8012d4:	5f                   	pop    %edi
  8012d5:	5d                   	pop    %ebp
  8012d6:	c3                   	ret    

008012d7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	57                   	push   %edi
  8012db:	56                   	push   %esi
  8012dc:	53                   	push   %ebx
  8012dd:	83 ec 18             	sub    $0x18,%esp
  8012e0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8012e3:	57                   	push   %edi
  8012e4:	e8 7a f6 ff ff       	call   800963 <fd2data>
  8012e9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f3:	eb 3d                	jmp    801332 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8012f5:	85 db                	test   %ebx,%ebx
  8012f7:	74 04                	je     8012fd <devpipe_read+0x26>
				return i;
  8012f9:	89 d8                	mov    %ebx,%eax
  8012fb:	eb 44                	jmp    801341 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8012fd:	89 f2                	mov    %esi,%edx
  8012ff:	89 f8                	mov    %edi,%eax
  801301:	e8 dc fe ff ff       	call   8011e2 <_pipeisclosed>
  801306:	85 c0                	test   %eax,%eax
  801308:	75 32                	jne    80133c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80130a:	e8 58 ee ff ff       	call   800167 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80130f:	8b 06                	mov    (%esi),%eax
  801311:	3b 46 04             	cmp    0x4(%esi),%eax
  801314:	74 df                	je     8012f5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801316:	99                   	cltd   
  801317:	c1 ea 1b             	shr    $0x1b,%edx
  80131a:	01 d0                	add    %edx,%eax
  80131c:	83 e0 1f             	and    $0x1f,%eax
  80131f:	29 d0                	sub    %edx,%eax
  801321:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801326:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801329:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80132c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80132f:	83 c3 01             	add    $0x1,%ebx
  801332:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801335:	75 d8                	jne    80130f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801337:	8b 45 10             	mov    0x10(%ebp),%eax
  80133a:	eb 05                	jmp    801341 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80133c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801341:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801344:	5b                   	pop    %ebx
  801345:	5e                   	pop    %esi
  801346:	5f                   	pop    %edi
  801347:	5d                   	pop    %ebp
  801348:	c3                   	ret    

00801349 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	56                   	push   %esi
  80134d:	53                   	push   %ebx
  80134e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801351:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	e8 20 f6 ff ff       	call   80097a <fd_alloc>
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	89 c2                	mov    %eax,%edx
  80135f:	85 c0                	test   %eax,%eax
  801361:	0f 88 2c 01 00 00    	js     801493 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801367:	83 ec 04             	sub    $0x4,%esp
  80136a:	68 07 04 00 00       	push   $0x407
  80136f:	ff 75 f4             	pushl  -0xc(%ebp)
  801372:	6a 00                	push   $0x0
  801374:	e8 0d ee ff ff       	call   800186 <sys_page_alloc>
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	89 c2                	mov    %eax,%edx
  80137e:	85 c0                	test   %eax,%eax
  801380:	0f 88 0d 01 00 00    	js     801493 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801386:	83 ec 0c             	sub    $0xc,%esp
  801389:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	e8 e8 f5 ff ff       	call   80097a <fd_alloc>
  801392:	89 c3                	mov    %eax,%ebx
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	85 c0                	test   %eax,%eax
  801399:	0f 88 e2 00 00 00    	js     801481 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80139f:	83 ec 04             	sub    $0x4,%esp
  8013a2:	68 07 04 00 00       	push   $0x407
  8013a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8013aa:	6a 00                	push   $0x0
  8013ac:	e8 d5 ed ff ff       	call   800186 <sys_page_alloc>
  8013b1:	89 c3                	mov    %eax,%ebx
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	0f 88 c3 00 00 00    	js     801481 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8013be:	83 ec 0c             	sub    $0xc,%esp
  8013c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c4:	e8 9a f5 ff ff       	call   800963 <fd2data>
  8013c9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013cb:	83 c4 0c             	add    $0xc,%esp
  8013ce:	68 07 04 00 00       	push   $0x407
  8013d3:	50                   	push   %eax
  8013d4:	6a 00                	push   $0x0
  8013d6:	e8 ab ed ff ff       	call   800186 <sys_page_alloc>
  8013db:	89 c3                	mov    %eax,%ebx
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	0f 88 89 00 00 00    	js     801471 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013e8:	83 ec 0c             	sub    $0xc,%esp
  8013eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ee:	e8 70 f5 ff ff       	call   800963 <fd2data>
  8013f3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8013fa:	50                   	push   %eax
  8013fb:	6a 00                	push   $0x0
  8013fd:	56                   	push   %esi
  8013fe:	6a 00                	push   $0x0
  801400:	e8 c4 ed ff ff       	call   8001c9 <sys_page_map>
  801405:	89 c3                	mov    %eax,%ebx
  801407:	83 c4 20             	add    $0x20,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 55                	js     801463 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80140e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801414:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801417:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801419:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801423:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801429:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80142e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801431:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801438:	83 ec 0c             	sub    $0xc,%esp
  80143b:	ff 75 f4             	pushl  -0xc(%ebp)
  80143e:	e8 10 f5 ff ff       	call   800953 <fd2num>
  801443:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801446:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801448:	83 c4 04             	add    $0x4,%esp
  80144b:	ff 75 f0             	pushl  -0x10(%ebp)
  80144e:	e8 00 f5 ff ff       	call   800953 <fd2num>
  801453:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801456:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	ba 00 00 00 00       	mov    $0x0,%edx
  801461:	eb 30                	jmp    801493 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	56                   	push   %esi
  801467:	6a 00                	push   $0x0
  801469:	e8 9d ed ff ff       	call   80020b <sys_page_unmap>
  80146e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	ff 75 f0             	pushl  -0x10(%ebp)
  801477:	6a 00                	push   $0x0
  801479:	e8 8d ed ff ff       	call   80020b <sys_page_unmap>
  80147e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	ff 75 f4             	pushl  -0xc(%ebp)
  801487:	6a 00                	push   $0x0
  801489:	e8 7d ed ff ff       	call   80020b <sys_page_unmap>
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801493:	89 d0                	mov    %edx,%eax
  801495:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801498:	5b                   	pop    %ebx
  801499:	5e                   	pop    %esi
  80149a:	5d                   	pop    %ebp
  80149b:	c3                   	ret    

0080149c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a5:	50                   	push   %eax
  8014a6:	ff 75 08             	pushl  0x8(%ebp)
  8014a9:	e8 1b f5 ff ff       	call   8009c9 <fd_lookup>
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 18                	js     8014cd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8014b5:	83 ec 0c             	sub    $0xc,%esp
  8014b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8014bb:	e8 a3 f4 ff ff       	call   800963 <fd2data>
	return _pipeisclosed(fd, p);
  8014c0:	89 c2                	mov    %eax,%edx
  8014c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c5:	e8 18 fd ff ff       	call   8011e2 <_pipeisclosed>
  8014ca:	83 c4 10             	add    $0x10,%esp
}
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8014d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    

008014d9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8014df:	68 f2 26 80 00       	push   $0x8026f2
  8014e4:	ff 75 0c             	pushl  0xc(%ebp)
  8014e7:	e8 c4 07 00 00       	call   801cb0 <strcpy>
	return 0;
}
  8014ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f1:	c9                   	leave  
  8014f2:	c3                   	ret    

008014f3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	57                   	push   %edi
  8014f7:	56                   	push   %esi
  8014f8:	53                   	push   %ebx
  8014f9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014ff:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801504:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80150a:	eb 2d                	jmp    801539 <devcons_write+0x46>
		m = n - tot;
  80150c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80150f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801511:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801514:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801519:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80151c:	83 ec 04             	sub    $0x4,%esp
  80151f:	53                   	push   %ebx
  801520:	03 45 0c             	add    0xc(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	57                   	push   %edi
  801525:	e8 18 09 00 00       	call   801e42 <memmove>
		sys_cputs(buf, m);
  80152a:	83 c4 08             	add    $0x8,%esp
  80152d:	53                   	push   %ebx
  80152e:	57                   	push   %edi
  80152f:	e8 96 eb ff ff       	call   8000ca <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801534:	01 de                	add    %ebx,%esi
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	89 f0                	mov    %esi,%eax
  80153b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80153e:	72 cc                	jb     80150c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801540:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801543:	5b                   	pop    %ebx
  801544:	5e                   	pop    %esi
  801545:	5f                   	pop    %edi
  801546:	5d                   	pop    %ebp
  801547:	c3                   	ret    

00801548 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801553:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801557:	74 2a                	je     801583 <devcons_read+0x3b>
  801559:	eb 05                	jmp    801560 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80155b:	e8 07 ec ff ff       	call   800167 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801560:	e8 83 eb ff ff       	call   8000e8 <sys_cgetc>
  801565:	85 c0                	test   %eax,%eax
  801567:	74 f2                	je     80155b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 16                	js     801583 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80156d:	83 f8 04             	cmp    $0x4,%eax
  801570:	74 0c                	je     80157e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801572:	8b 55 0c             	mov    0xc(%ebp),%edx
  801575:	88 02                	mov    %al,(%edx)
	return 1;
  801577:	b8 01 00 00 00       	mov    $0x1,%eax
  80157c:	eb 05                	jmp    801583 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80157e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801583:	c9                   	leave  
  801584:	c3                   	ret    

00801585 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80158b:	8b 45 08             	mov    0x8(%ebp),%eax
  80158e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801591:	6a 01                	push   $0x1
  801593:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801596:	50                   	push   %eax
  801597:	e8 2e eb ff ff       	call   8000ca <sys_cputs>
}
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <getchar>:

int
getchar(void)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8015a7:	6a 01                	push   $0x1
  8015a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	6a 00                	push   $0x0
  8015af:	e8 7e f6 ff ff       	call   800c32 <read>
	if (r < 0)
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 0f                	js     8015ca <getchar+0x29>
		return r;
	if (r < 1)
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	7e 06                	jle    8015c5 <getchar+0x24>
		return -E_EOF;
	return c;
  8015bf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8015c3:	eb 05                	jmp    8015ca <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8015c5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d5:	50                   	push   %eax
  8015d6:	ff 75 08             	pushl  0x8(%ebp)
  8015d9:	e8 eb f3 ff ff       	call   8009c9 <fd_lookup>
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 11                	js     8015f6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8015e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015ee:	39 10                	cmp    %edx,(%eax)
  8015f0:	0f 94 c0             	sete   %al
  8015f3:	0f b6 c0             	movzbl %al,%eax
}
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <opencons>:

int
opencons(void)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8015fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	e8 73 f3 ff ff       	call   80097a <fd_alloc>
  801607:	83 c4 10             	add    $0x10,%esp
		return r;
  80160a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 3e                	js     80164e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801610:	83 ec 04             	sub    $0x4,%esp
  801613:	68 07 04 00 00       	push   $0x407
  801618:	ff 75 f4             	pushl  -0xc(%ebp)
  80161b:	6a 00                	push   $0x0
  80161d:	e8 64 eb ff ff       	call   800186 <sys_page_alloc>
  801622:	83 c4 10             	add    $0x10,%esp
		return r;
  801625:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801627:	85 c0                	test   %eax,%eax
  801629:	78 23                	js     80164e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80162b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801631:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801634:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801636:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801639:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801640:	83 ec 0c             	sub    $0xc,%esp
  801643:	50                   	push   %eax
  801644:	e8 0a f3 ff ff       	call   800953 <fd2num>
  801649:	89 c2                	mov    %eax,%edx
  80164b:	83 c4 10             	add    $0x10,%esp
}
  80164e:	89 d0                	mov    %edx,%eax
  801650:	c9                   	leave  
  801651:	c3                   	ret    

00801652 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	56                   	push   %esi
  801656:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801657:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80165a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801660:	e8 e3 ea ff ff       	call   800148 <sys_getenvid>
  801665:	83 ec 0c             	sub    $0xc,%esp
  801668:	ff 75 0c             	pushl  0xc(%ebp)
  80166b:	ff 75 08             	pushl  0x8(%ebp)
  80166e:	56                   	push   %esi
  80166f:	50                   	push   %eax
  801670:	68 00 27 80 00       	push   $0x802700
  801675:	e8 b1 00 00 00       	call   80172b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80167a:	83 c4 18             	add    $0x18,%esp
  80167d:	53                   	push   %ebx
  80167e:	ff 75 10             	pushl  0x10(%ebp)
  801681:	e8 54 00 00 00       	call   8016da <vcprintf>
	cprintf("\n");
  801686:	c7 04 24 51 25 80 00 	movl   $0x802551,(%esp)
  80168d:	e8 99 00 00 00       	call   80172b <cprintf>
  801692:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801695:	cc                   	int3   
  801696:	eb fd                	jmp    801695 <_panic+0x43>

00801698 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	53                   	push   %ebx
  80169c:	83 ec 04             	sub    $0x4,%esp
  80169f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8016a2:	8b 13                	mov    (%ebx),%edx
  8016a4:	8d 42 01             	lea    0x1(%edx),%eax
  8016a7:	89 03                	mov    %eax,(%ebx)
  8016a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8016b0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8016b5:	75 1a                	jne    8016d1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8016b7:	83 ec 08             	sub    $0x8,%esp
  8016ba:	68 ff 00 00 00       	push   $0xff
  8016bf:	8d 43 08             	lea    0x8(%ebx),%eax
  8016c2:	50                   	push   %eax
  8016c3:	e8 02 ea ff ff       	call   8000ca <sys_cputs>
		b->idx = 0;
  8016c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016ce:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8016d1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8016d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8016e3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016ea:	00 00 00 
	b.cnt = 0;
  8016ed:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8016f4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8016f7:	ff 75 0c             	pushl  0xc(%ebp)
  8016fa:	ff 75 08             	pushl  0x8(%ebp)
  8016fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801703:	50                   	push   %eax
  801704:	68 98 16 80 00       	push   $0x801698
  801709:	e8 54 01 00 00       	call   801862 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80170e:	83 c4 08             	add    $0x8,%esp
  801711:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801717:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80171d:	50                   	push   %eax
  80171e:	e8 a7 e9 ff ff       	call   8000ca <sys_cputs>

	return b.cnt;
}
  801723:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801729:	c9                   	leave  
  80172a:	c3                   	ret    

0080172b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801731:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801734:	50                   	push   %eax
  801735:	ff 75 08             	pushl  0x8(%ebp)
  801738:	e8 9d ff ff ff       	call   8016da <vcprintf>
	va_end(ap);

	return cnt;
}
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    

0080173f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	57                   	push   %edi
  801743:	56                   	push   %esi
  801744:	53                   	push   %ebx
  801745:	83 ec 1c             	sub    $0x1c,%esp
  801748:	89 c7                	mov    %eax,%edi
  80174a:	89 d6                	mov    %edx,%esi
  80174c:	8b 45 08             	mov    0x8(%ebp),%eax
  80174f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801752:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801755:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801758:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80175b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801760:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801763:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801766:	39 d3                	cmp    %edx,%ebx
  801768:	72 05                	jb     80176f <printnum+0x30>
  80176a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80176d:	77 45                	ja     8017b4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80176f:	83 ec 0c             	sub    $0xc,%esp
  801772:	ff 75 18             	pushl  0x18(%ebp)
  801775:	8b 45 14             	mov    0x14(%ebp),%eax
  801778:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80177b:	53                   	push   %ebx
  80177c:	ff 75 10             	pushl  0x10(%ebp)
  80177f:	83 ec 08             	sub    $0x8,%esp
  801782:	ff 75 e4             	pushl  -0x1c(%ebp)
  801785:	ff 75 e0             	pushl  -0x20(%ebp)
  801788:	ff 75 dc             	pushl  -0x24(%ebp)
  80178b:	ff 75 d8             	pushl  -0x28(%ebp)
  80178e:	e8 5d 0a 00 00       	call   8021f0 <__udivdi3>
  801793:	83 c4 18             	add    $0x18,%esp
  801796:	52                   	push   %edx
  801797:	50                   	push   %eax
  801798:	89 f2                	mov    %esi,%edx
  80179a:	89 f8                	mov    %edi,%eax
  80179c:	e8 9e ff ff ff       	call   80173f <printnum>
  8017a1:	83 c4 20             	add    $0x20,%esp
  8017a4:	eb 18                	jmp    8017be <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8017a6:	83 ec 08             	sub    $0x8,%esp
  8017a9:	56                   	push   %esi
  8017aa:	ff 75 18             	pushl  0x18(%ebp)
  8017ad:	ff d7                	call   *%edi
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	eb 03                	jmp    8017b7 <printnum+0x78>
  8017b4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8017b7:	83 eb 01             	sub    $0x1,%ebx
  8017ba:	85 db                	test   %ebx,%ebx
  8017bc:	7f e8                	jg     8017a6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017be:	83 ec 08             	sub    $0x8,%esp
  8017c1:	56                   	push   %esi
  8017c2:	83 ec 04             	sub    $0x4,%esp
  8017c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8017cb:	ff 75 dc             	pushl  -0x24(%ebp)
  8017ce:	ff 75 d8             	pushl  -0x28(%ebp)
  8017d1:	e8 4a 0b 00 00       	call   802320 <__umoddi3>
  8017d6:	83 c4 14             	add    $0x14,%esp
  8017d9:	0f be 80 23 27 80 00 	movsbl 0x802723(%eax),%eax
  8017e0:	50                   	push   %eax
  8017e1:	ff d7                	call   *%edi
}
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e9:	5b                   	pop    %ebx
  8017ea:	5e                   	pop    %esi
  8017eb:	5f                   	pop    %edi
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8017f1:	83 fa 01             	cmp    $0x1,%edx
  8017f4:	7e 0e                	jle    801804 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8017f6:	8b 10                	mov    (%eax),%edx
  8017f8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8017fb:	89 08                	mov    %ecx,(%eax)
  8017fd:	8b 02                	mov    (%edx),%eax
  8017ff:	8b 52 04             	mov    0x4(%edx),%edx
  801802:	eb 22                	jmp    801826 <getuint+0x38>
	else if (lflag)
  801804:	85 d2                	test   %edx,%edx
  801806:	74 10                	je     801818 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801808:	8b 10                	mov    (%eax),%edx
  80180a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80180d:	89 08                	mov    %ecx,(%eax)
  80180f:	8b 02                	mov    (%edx),%eax
  801811:	ba 00 00 00 00       	mov    $0x0,%edx
  801816:	eb 0e                	jmp    801826 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801818:	8b 10                	mov    (%eax),%edx
  80181a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80181d:	89 08                	mov    %ecx,(%eax)
  80181f:	8b 02                	mov    (%edx),%eax
  801821:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801826:	5d                   	pop    %ebp
  801827:	c3                   	ret    

00801828 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80182e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801832:	8b 10                	mov    (%eax),%edx
  801834:	3b 50 04             	cmp    0x4(%eax),%edx
  801837:	73 0a                	jae    801843 <sprintputch+0x1b>
		*b->buf++ = ch;
  801839:	8d 4a 01             	lea    0x1(%edx),%ecx
  80183c:	89 08                	mov    %ecx,(%eax)
  80183e:	8b 45 08             	mov    0x8(%ebp),%eax
  801841:	88 02                	mov    %al,(%edx)
}
  801843:	5d                   	pop    %ebp
  801844:	c3                   	ret    

00801845 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80184b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80184e:	50                   	push   %eax
  80184f:	ff 75 10             	pushl  0x10(%ebp)
  801852:	ff 75 0c             	pushl  0xc(%ebp)
  801855:	ff 75 08             	pushl  0x8(%ebp)
  801858:	e8 05 00 00 00       	call   801862 <vprintfmt>
	va_end(ap);
}
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	57                   	push   %edi
  801866:	56                   	push   %esi
  801867:	53                   	push   %ebx
  801868:	83 ec 2c             	sub    $0x2c,%esp
  80186b:	8b 75 08             	mov    0x8(%ebp),%esi
  80186e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801871:	8b 7d 10             	mov    0x10(%ebp),%edi
  801874:	eb 12                	jmp    801888 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801876:	85 c0                	test   %eax,%eax
  801878:	0f 84 89 03 00 00    	je     801c07 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80187e:	83 ec 08             	sub    $0x8,%esp
  801881:	53                   	push   %ebx
  801882:	50                   	push   %eax
  801883:	ff d6                	call   *%esi
  801885:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801888:	83 c7 01             	add    $0x1,%edi
  80188b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80188f:	83 f8 25             	cmp    $0x25,%eax
  801892:	75 e2                	jne    801876 <vprintfmt+0x14>
  801894:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801898:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80189f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018a6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8018ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b2:	eb 07                	jmp    8018bb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8018b7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018bb:	8d 47 01             	lea    0x1(%edi),%eax
  8018be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018c1:	0f b6 07             	movzbl (%edi),%eax
  8018c4:	0f b6 c8             	movzbl %al,%ecx
  8018c7:	83 e8 23             	sub    $0x23,%eax
  8018ca:	3c 55                	cmp    $0x55,%al
  8018cc:	0f 87 1a 03 00 00    	ja     801bec <vprintfmt+0x38a>
  8018d2:	0f b6 c0             	movzbl %al,%eax
  8018d5:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  8018dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8018df:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8018e3:	eb d6                	jmp    8018bb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8018f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8018f3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8018f7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8018fa:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8018fd:	83 fa 09             	cmp    $0x9,%edx
  801900:	77 39                	ja     80193b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801902:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801905:	eb e9                	jmp    8018f0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801907:	8b 45 14             	mov    0x14(%ebp),%eax
  80190a:	8d 48 04             	lea    0x4(%eax),%ecx
  80190d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801910:	8b 00                	mov    (%eax),%eax
  801912:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801915:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801918:	eb 27                	jmp    801941 <vprintfmt+0xdf>
  80191a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80191d:	85 c0                	test   %eax,%eax
  80191f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801924:	0f 49 c8             	cmovns %eax,%ecx
  801927:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80192d:	eb 8c                	jmp    8018bb <vprintfmt+0x59>
  80192f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801932:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801939:	eb 80                	jmp    8018bb <vprintfmt+0x59>
  80193b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80193e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801941:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801945:	0f 89 70 ff ff ff    	jns    8018bb <vprintfmt+0x59>
				width = precision, precision = -1;
  80194b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80194e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801951:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801958:	e9 5e ff ff ff       	jmp    8018bb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80195d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801960:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801963:	e9 53 ff ff ff       	jmp    8018bb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801968:	8b 45 14             	mov    0x14(%ebp),%eax
  80196b:	8d 50 04             	lea    0x4(%eax),%edx
  80196e:	89 55 14             	mov    %edx,0x14(%ebp)
  801971:	83 ec 08             	sub    $0x8,%esp
  801974:	53                   	push   %ebx
  801975:	ff 30                	pushl  (%eax)
  801977:	ff d6                	call   *%esi
			break;
  801979:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80197c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80197f:	e9 04 ff ff ff       	jmp    801888 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801984:	8b 45 14             	mov    0x14(%ebp),%eax
  801987:	8d 50 04             	lea    0x4(%eax),%edx
  80198a:	89 55 14             	mov    %edx,0x14(%ebp)
  80198d:	8b 00                	mov    (%eax),%eax
  80198f:	99                   	cltd   
  801990:	31 d0                	xor    %edx,%eax
  801992:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801994:	83 f8 0f             	cmp    $0xf,%eax
  801997:	7f 0b                	jg     8019a4 <vprintfmt+0x142>
  801999:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  8019a0:	85 d2                	test   %edx,%edx
  8019a2:	75 18                	jne    8019bc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8019a4:	50                   	push   %eax
  8019a5:	68 3b 27 80 00       	push   $0x80273b
  8019aa:	53                   	push   %ebx
  8019ab:	56                   	push   %esi
  8019ac:	e8 94 fe ff ff       	call   801845 <printfmt>
  8019b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8019b7:	e9 cc fe ff ff       	jmp    801888 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8019bc:	52                   	push   %edx
  8019bd:	68 b9 26 80 00       	push   $0x8026b9
  8019c2:	53                   	push   %ebx
  8019c3:	56                   	push   %esi
  8019c4:	e8 7c fe ff ff       	call   801845 <printfmt>
  8019c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019cf:	e9 b4 fe ff ff       	jmp    801888 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8019d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d7:	8d 50 04             	lea    0x4(%eax),%edx
  8019da:	89 55 14             	mov    %edx,0x14(%ebp)
  8019dd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8019df:	85 ff                	test   %edi,%edi
  8019e1:	b8 34 27 80 00       	mov    $0x802734,%eax
  8019e6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8019e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8019ed:	0f 8e 94 00 00 00    	jle    801a87 <vprintfmt+0x225>
  8019f3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8019f7:	0f 84 98 00 00 00    	je     801a95 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8019fd:	83 ec 08             	sub    $0x8,%esp
  801a00:	ff 75 d0             	pushl  -0x30(%ebp)
  801a03:	57                   	push   %edi
  801a04:	e8 86 02 00 00       	call   801c8f <strnlen>
  801a09:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801a0c:	29 c1                	sub    %eax,%ecx
  801a0e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801a11:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801a14:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801a18:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a1b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801a1e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a20:	eb 0f                	jmp    801a31 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801a22:	83 ec 08             	sub    $0x8,%esp
  801a25:	53                   	push   %ebx
  801a26:	ff 75 e0             	pushl  -0x20(%ebp)
  801a29:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a2b:	83 ef 01             	sub    $0x1,%edi
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	85 ff                	test   %edi,%edi
  801a33:	7f ed                	jg     801a22 <vprintfmt+0x1c0>
  801a35:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801a38:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801a3b:	85 c9                	test   %ecx,%ecx
  801a3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a42:	0f 49 c1             	cmovns %ecx,%eax
  801a45:	29 c1                	sub    %eax,%ecx
  801a47:	89 75 08             	mov    %esi,0x8(%ebp)
  801a4a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a4d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a50:	89 cb                	mov    %ecx,%ebx
  801a52:	eb 4d                	jmp    801aa1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a54:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a58:	74 1b                	je     801a75 <vprintfmt+0x213>
  801a5a:	0f be c0             	movsbl %al,%eax
  801a5d:	83 e8 20             	sub    $0x20,%eax
  801a60:	83 f8 5e             	cmp    $0x5e,%eax
  801a63:	76 10                	jbe    801a75 <vprintfmt+0x213>
					putch('?', putdat);
  801a65:	83 ec 08             	sub    $0x8,%esp
  801a68:	ff 75 0c             	pushl  0xc(%ebp)
  801a6b:	6a 3f                	push   $0x3f
  801a6d:	ff 55 08             	call   *0x8(%ebp)
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	eb 0d                	jmp    801a82 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801a75:	83 ec 08             	sub    $0x8,%esp
  801a78:	ff 75 0c             	pushl  0xc(%ebp)
  801a7b:	52                   	push   %edx
  801a7c:	ff 55 08             	call   *0x8(%ebp)
  801a7f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a82:	83 eb 01             	sub    $0x1,%ebx
  801a85:	eb 1a                	jmp    801aa1 <vprintfmt+0x23f>
  801a87:	89 75 08             	mov    %esi,0x8(%ebp)
  801a8a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a8d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a90:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a93:	eb 0c                	jmp    801aa1 <vprintfmt+0x23f>
  801a95:	89 75 08             	mov    %esi,0x8(%ebp)
  801a98:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a9b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a9e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801aa1:	83 c7 01             	add    $0x1,%edi
  801aa4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801aa8:	0f be d0             	movsbl %al,%edx
  801aab:	85 d2                	test   %edx,%edx
  801aad:	74 23                	je     801ad2 <vprintfmt+0x270>
  801aaf:	85 f6                	test   %esi,%esi
  801ab1:	78 a1                	js     801a54 <vprintfmt+0x1f2>
  801ab3:	83 ee 01             	sub    $0x1,%esi
  801ab6:	79 9c                	jns    801a54 <vprintfmt+0x1f2>
  801ab8:	89 df                	mov    %ebx,%edi
  801aba:	8b 75 08             	mov    0x8(%ebp),%esi
  801abd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ac0:	eb 18                	jmp    801ada <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801ac2:	83 ec 08             	sub    $0x8,%esp
  801ac5:	53                   	push   %ebx
  801ac6:	6a 20                	push   $0x20
  801ac8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801aca:	83 ef 01             	sub    $0x1,%edi
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	eb 08                	jmp    801ada <vprintfmt+0x278>
  801ad2:	89 df                	mov    %ebx,%edi
  801ad4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ad7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ada:	85 ff                	test   %edi,%edi
  801adc:	7f e4                	jg     801ac2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ade:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ae1:	e9 a2 fd ff ff       	jmp    801888 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801ae6:	83 fa 01             	cmp    $0x1,%edx
  801ae9:	7e 16                	jle    801b01 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801aeb:	8b 45 14             	mov    0x14(%ebp),%eax
  801aee:	8d 50 08             	lea    0x8(%eax),%edx
  801af1:	89 55 14             	mov    %edx,0x14(%ebp)
  801af4:	8b 50 04             	mov    0x4(%eax),%edx
  801af7:	8b 00                	mov    (%eax),%eax
  801af9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801afc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801aff:	eb 32                	jmp    801b33 <vprintfmt+0x2d1>
	else if (lflag)
  801b01:	85 d2                	test   %edx,%edx
  801b03:	74 18                	je     801b1d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801b05:	8b 45 14             	mov    0x14(%ebp),%eax
  801b08:	8d 50 04             	lea    0x4(%eax),%edx
  801b0b:	89 55 14             	mov    %edx,0x14(%ebp)
  801b0e:	8b 00                	mov    (%eax),%eax
  801b10:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b13:	89 c1                	mov    %eax,%ecx
  801b15:	c1 f9 1f             	sar    $0x1f,%ecx
  801b18:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801b1b:	eb 16                	jmp    801b33 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801b1d:	8b 45 14             	mov    0x14(%ebp),%eax
  801b20:	8d 50 04             	lea    0x4(%eax),%edx
  801b23:	89 55 14             	mov    %edx,0x14(%ebp)
  801b26:	8b 00                	mov    (%eax),%eax
  801b28:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b2b:	89 c1                	mov    %eax,%ecx
  801b2d:	c1 f9 1f             	sar    $0x1f,%ecx
  801b30:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801b33:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b36:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801b39:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801b3e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b42:	79 74                	jns    801bb8 <vprintfmt+0x356>
				putch('-', putdat);
  801b44:	83 ec 08             	sub    $0x8,%esp
  801b47:	53                   	push   %ebx
  801b48:	6a 2d                	push   $0x2d
  801b4a:	ff d6                	call   *%esi
				num = -(long long) num;
  801b4c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b4f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b52:	f7 d8                	neg    %eax
  801b54:	83 d2 00             	adc    $0x0,%edx
  801b57:	f7 da                	neg    %edx
  801b59:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801b5c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801b61:	eb 55                	jmp    801bb8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b63:	8d 45 14             	lea    0x14(%ebp),%eax
  801b66:	e8 83 fc ff ff       	call   8017ee <getuint>
			base = 10;
  801b6b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801b70:	eb 46                	jmp    801bb8 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801b72:	8d 45 14             	lea    0x14(%ebp),%eax
  801b75:	e8 74 fc ff ff       	call   8017ee <getuint>
			base = 8;
  801b7a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b7f:	eb 37                	jmp    801bb8 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b81:	83 ec 08             	sub    $0x8,%esp
  801b84:	53                   	push   %ebx
  801b85:	6a 30                	push   $0x30
  801b87:	ff d6                	call   *%esi
			putch('x', putdat);
  801b89:	83 c4 08             	add    $0x8,%esp
  801b8c:	53                   	push   %ebx
  801b8d:	6a 78                	push   $0x78
  801b8f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b91:	8b 45 14             	mov    0x14(%ebp),%eax
  801b94:	8d 50 04             	lea    0x4(%eax),%edx
  801b97:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b9a:	8b 00                	mov    (%eax),%eax
  801b9c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ba1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ba4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ba9:	eb 0d                	jmp    801bb8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801bab:	8d 45 14             	lea    0x14(%ebp),%eax
  801bae:	e8 3b fc ff ff       	call   8017ee <getuint>
			base = 16;
  801bb3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801bb8:	83 ec 0c             	sub    $0xc,%esp
  801bbb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801bbf:	57                   	push   %edi
  801bc0:	ff 75 e0             	pushl  -0x20(%ebp)
  801bc3:	51                   	push   %ecx
  801bc4:	52                   	push   %edx
  801bc5:	50                   	push   %eax
  801bc6:	89 da                	mov    %ebx,%edx
  801bc8:	89 f0                	mov    %esi,%eax
  801bca:	e8 70 fb ff ff       	call   80173f <printnum>
			break;
  801bcf:	83 c4 20             	add    $0x20,%esp
  801bd2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bd5:	e9 ae fc ff ff       	jmp    801888 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801bda:	83 ec 08             	sub    $0x8,%esp
  801bdd:	53                   	push   %ebx
  801bde:	51                   	push   %ecx
  801bdf:	ff d6                	call   *%esi
			break;
  801be1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801be4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801be7:	e9 9c fc ff ff       	jmp    801888 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801bec:	83 ec 08             	sub    $0x8,%esp
  801bef:	53                   	push   %ebx
  801bf0:	6a 25                	push   $0x25
  801bf2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	eb 03                	jmp    801bfc <vprintfmt+0x39a>
  801bf9:	83 ef 01             	sub    $0x1,%edi
  801bfc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801c00:	75 f7                	jne    801bf9 <vprintfmt+0x397>
  801c02:	e9 81 fc ff ff       	jmp    801888 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0a:	5b                   	pop    %ebx
  801c0b:	5e                   	pop    %esi
  801c0c:	5f                   	pop    %edi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	83 ec 18             	sub    $0x18,%esp
  801c15:	8b 45 08             	mov    0x8(%ebp),%eax
  801c18:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801c1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c1e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801c22:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	74 26                	je     801c56 <vsnprintf+0x47>
  801c30:	85 d2                	test   %edx,%edx
  801c32:	7e 22                	jle    801c56 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801c34:	ff 75 14             	pushl  0x14(%ebp)
  801c37:	ff 75 10             	pushl  0x10(%ebp)
  801c3a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c3d:	50                   	push   %eax
  801c3e:	68 28 18 80 00       	push   $0x801828
  801c43:	e8 1a fc ff ff       	call   801862 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801c48:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c4b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	eb 05                	jmp    801c5b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c56:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c63:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c66:	50                   	push   %eax
  801c67:	ff 75 10             	pushl  0x10(%ebp)
  801c6a:	ff 75 0c             	pushl  0xc(%ebp)
  801c6d:	ff 75 08             	pushl  0x8(%ebp)
  801c70:	e8 9a ff ff ff       	call   801c0f <vsnprintf>
	va_end(ap);

	return rc;
}
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c82:	eb 03                	jmp    801c87 <strlen+0x10>
		n++;
  801c84:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c87:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c8b:	75 f7                	jne    801c84 <strlen+0xd>
		n++;
	return n;
}
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    

00801c8f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c95:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c98:	ba 00 00 00 00       	mov    $0x0,%edx
  801c9d:	eb 03                	jmp    801ca2 <strnlen+0x13>
		n++;
  801c9f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ca2:	39 c2                	cmp    %eax,%edx
  801ca4:	74 08                	je     801cae <strnlen+0x1f>
  801ca6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801caa:	75 f3                	jne    801c9f <strnlen+0x10>
  801cac:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801cae:	5d                   	pop    %ebp
  801caf:	c3                   	ret    

00801cb0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	53                   	push   %ebx
  801cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801cba:	89 c2                	mov    %eax,%edx
  801cbc:	83 c2 01             	add    $0x1,%edx
  801cbf:	83 c1 01             	add    $0x1,%ecx
  801cc2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801cc6:	88 5a ff             	mov    %bl,-0x1(%edx)
  801cc9:	84 db                	test   %bl,%bl
  801ccb:	75 ef                	jne    801cbc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801ccd:	5b                   	pop    %ebx
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    

00801cd0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	53                   	push   %ebx
  801cd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801cd7:	53                   	push   %ebx
  801cd8:	e8 9a ff ff ff       	call   801c77 <strlen>
  801cdd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801ce0:	ff 75 0c             	pushl  0xc(%ebp)
  801ce3:	01 d8                	add    %ebx,%eax
  801ce5:	50                   	push   %eax
  801ce6:	e8 c5 ff ff ff       	call   801cb0 <strcpy>
	return dst;
}
  801ceb:	89 d8                	mov    %ebx,%eax
  801ced:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	56                   	push   %esi
  801cf6:	53                   	push   %ebx
  801cf7:	8b 75 08             	mov    0x8(%ebp),%esi
  801cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cfd:	89 f3                	mov    %esi,%ebx
  801cff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d02:	89 f2                	mov    %esi,%edx
  801d04:	eb 0f                	jmp    801d15 <strncpy+0x23>
		*dst++ = *src;
  801d06:	83 c2 01             	add    $0x1,%edx
  801d09:	0f b6 01             	movzbl (%ecx),%eax
  801d0c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801d0f:	80 39 01             	cmpb   $0x1,(%ecx)
  801d12:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d15:	39 da                	cmp    %ebx,%edx
  801d17:	75 ed                	jne    801d06 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801d19:	89 f0                	mov    %esi,%eax
  801d1b:	5b                   	pop    %ebx
  801d1c:	5e                   	pop    %esi
  801d1d:	5d                   	pop    %ebp
  801d1e:	c3                   	ret    

00801d1f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	8b 75 08             	mov    0x8(%ebp),%esi
  801d27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d2a:	8b 55 10             	mov    0x10(%ebp),%edx
  801d2d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801d2f:	85 d2                	test   %edx,%edx
  801d31:	74 21                	je     801d54 <strlcpy+0x35>
  801d33:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801d37:	89 f2                	mov    %esi,%edx
  801d39:	eb 09                	jmp    801d44 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801d3b:	83 c2 01             	add    $0x1,%edx
  801d3e:	83 c1 01             	add    $0x1,%ecx
  801d41:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801d44:	39 c2                	cmp    %eax,%edx
  801d46:	74 09                	je     801d51 <strlcpy+0x32>
  801d48:	0f b6 19             	movzbl (%ecx),%ebx
  801d4b:	84 db                	test   %bl,%bl
  801d4d:	75 ec                	jne    801d3b <strlcpy+0x1c>
  801d4f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801d51:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801d54:	29 f0                	sub    %esi,%eax
}
  801d56:	5b                   	pop    %ebx
  801d57:	5e                   	pop    %esi
  801d58:	5d                   	pop    %ebp
  801d59:	c3                   	ret    

00801d5a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d60:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801d63:	eb 06                	jmp    801d6b <strcmp+0x11>
		p++, q++;
  801d65:	83 c1 01             	add    $0x1,%ecx
  801d68:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801d6b:	0f b6 01             	movzbl (%ecx),%eax
  801d6e:	84 c0                	test   %al,%al
  801d70:	74 04                	je     801d76 <strcmp+0x1c>
  801d72:	3a 02                	cmp    (%edx),%al
  801d74:	74 ef                	je     801d65 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801d76:	0f b6 c0             	movzbl %al,%eax
  801d79:	0f b6 12             	movzbl (%edx),%edx
  801d7c:	29 d0                	sub    %edx,%eax
}
  801d7e:	5d                   	pop    %ebp
  801d7f:	c3                   	ret    

00801d80 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	53                   	push   %ebx
  801d84:	8b 45 08             	mov    0x8(%ebp),%eax
  801d87:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8a:	89 c3                	mov    %eax,%ebx
  801d8c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d8f:	eb 06                	jmp    801d97 <strncmp+0x17>
		n--, p++, q++;
  801d91:	83 c0 01             	add    $0x1,%eax
  801d94:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d97:	39 d8                	cmp    %ebx,%eax
  801d99:	74 15                	je     801db0 <strncmp+0x30>
  801d9b:	0f b6 08             	movzbl (%eax),%ecx
  801d9e:	84 c9                	test   %cl,%cl
  801da0:	74 04                	je     801da6 <strncmp+0x26>
  801da2:	3a 0a                	cmp    (%edx),%cl
  801da4:	74 eb                	je     801d91 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801da6:	0f b6 00             	movzbl (%eax),%eax
  801da9:	0f b6 12             	movzbl (%edx),%edx
  801dac:	29 d0                	sub    %edx,%eax
  801dae:	eb 05                	jmp    801db5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801db0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801db5:	5b                   	pop    %ebx
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    

00801db8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801dc2:	eb 07                	jmp    801dcb <strchr+0x13>
		if (*s == c)
  801dc4:	38 ca                	cmp    %cl,%dl
  801dc6:	74 0f                	je     801dd7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801dc8:	83 c0 01             	add    $0x1,%eax
  801dcb:	0f b6 10             	movzbl (%eax),%edx
  801dce:	84 d2                	test   %dl,%dl
  801dd0:	75 f2                	jne    801dc4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801dd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    

00801dd9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801de3:	eb 03                	jmp    801de8 <strfind+0xf>
  801de5:	83 c0 01             	add    $0x1,%eax
  801de8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801deb:	38 ca                	cmp    %cl,%dl
  801ded:	74 04                	je     801df3 <strfind+0x1a>
  801def:	84 d2                	test   %dl,%dl
  801df1:	75 f2                	jne    801de5 <strfind+0xc>
			break;
	return (char *) s;
}
  801df3:	5d                   	pop    %ebp
  801df4:	c3                   	ret    

00801df5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	57                   	push   %edi
  801df9:	56                   	push   %esi
  801dfa:	53                   	push   %ebx
  801dfb:	8b 7d 08             	mov    0x8(%ebp),%edi
  801dfe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801e01:	85 c9                	test   %ecx,%ecx
  801e03:	74 36                	je     801e3b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801e05:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801e0b:	75 28                	jne    801e35 <memset+0x40>
  801e0d:	f6 c1 03             	test   $0x3,%cl
  801e10:	75 23                	jne    801e35 <memset+0x40>
		c &= 0xFF;
  801e12:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801e16:	89 d3                	mov    %edx,%ebx
  801e18:	c1 e3 08             	shl    $0x8,%ebx
  801e1b:	89 d6                	mov    %edx,%esi
  801e1d:	c1 e6 18             	shl    $0x18,%esi
  801e20:	89 d0                	mov    %edx,%eax
  801e22:	c1 e0 10             	shl    $0x10,%eax
  801e25:	09 f0                	or     %esi,%eax
  801e27:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801e29:	89 d8                	mov    %ebx,%eax
  801e2b:	09 d0                	or     %edx,%eax
  801e2d:	c1 e9 02             	shr    $0x2,%ecx
  801e30:	fc                   	cld    
  801e31:	f3 ab                	rep stos %eax,%es:(%edi)
  801e33:	eb 06                	jmp    801e3b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801e35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e38:	fc                   	cld    
  801e39:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801e3b:	89 f8                	mov    %edi,%eax
  801e3d:	5b                   	pop    %ebx
  801e3e:	5e                   	pop    %esi
  801e3f:	5f                   	pop    %edi
  801e40:	5d                   	pop    %ebp
  801e41:	c3                   	ret    

00801e42 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	57                   	push   %edi
  801e46:	56                   	push   %esi
  801e47:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e50:	39 c6                	cmp    %eax,%esi
  801e52:	73 35                	jae    801e89 <memmove+0x47>
  801e54:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e57:	39 d0                	cmp    %edx,%eax
  801e59:	73 2e                	jae    801e89 <memmove+0x47>
		s += n;
		d += n;
  801e5b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e5e:	89 d6                	mov    %edx,%esi
  801e60:	09 fe                	or     %edi,%esi
  801e62:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e68:	75 13                	jne    801e7d <memmove+0x3b>
  801e6a:	f6 c1 03             	test   $0x3,%cl
  801e6d:	75 0e                	jne    801e7d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801e6f:	83 ef 04             	sub    $0x4,%edi
  801e72:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e75:	c1 e9 02             	shr    $0x2,%ecx
  801e78:	fd                   	std    
  801e79:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e7b:	eb 09                	jmp    801e86 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e7d:	83 ef 01             	sub    $0x1,%edi
  801e80:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e83:	fd                   	std    
  801e84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e86:	fc                   	cld    
  801e87:	eb 1d                	jmp    801ea6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e89:	89 f2                	mov    %esi,%edx
  801e8b:	09 c2                	or     %eax,%edx
  801e8d:	f6 c2 03             	test   $0x3,%dl
  801e90:	75 0f                	jne    801ea1 <memmove+0x5f>
  801e92:	f6 c1 03             	test   $0x3,%cl
  801e95:	75 0a                	jne    801ea1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e97:	c1 e9 02             	shr    $0x2,%ecx
  801e9a:	89 c7                	mov    %eax,%edi
  801e9c:	fc                   	cld    
  801e9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e9f:	eb 05                	jmp    801ea6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801ea1:	89 c7                	mov    %eax,%edi
  801ea3:	fc                   	cld    
  801ea4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801ea6:	5e                   	pop    %esi
  801ea7:	5f                   	pop    %edi
  801ea8:	5d                   	pop    %ebp
  801ea9:	c3                   	ret    

00801eaa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801ead:	ff 75 10             	pushl  0x10(%ebp)
  801eb0:	ff 75 0c             	pushl  0xc(%ebp)
  801eb3:	ff 75 08             	pushl  0x8(%ebp)
  801eb6:	e8 87 ff ff ff       	call   801e42 <memmove>
}
  801ebb:	c9                   	leave  
  801ebc:	c3                   	ret    

00801ebd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801ebd:	55                   	push   %ebp
  801ebe:	89 e5                	mov    %esp,%ebp
  801ec0:	56                   	push   %esi
  801ec1:	53                   	push   %ebx
  801ec2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec8:	89 c6                	mov    %eax,%esi
  801eca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ecd:	eb 1a                	jmp    801ee9 <memcmp+0x2c>
		if (*s1 != *s2)
  801ecf:	0f b6 08             	movzbl (%eax),%ecx
  801ed2:	0f b6 1a             	movzbl (%edx),%ebx
  801ed5:	38 d9                	cmp    %bl,%cl
  801ed7:	74 0a                	je     801ee3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801ed9:	0f b6 c1             	movzbl %cl,%eax
  801edc:	0f b6 db             	movzbl %bl,%ebx
  801edf:	29 d8                	sub    %ebx,%eax
  801ee1:	eb 0f                	jmp    801ef2 <memcmp+0x35>
		s1++, s2++;
  801ee3:	83 c0 01             	add    $0x1,%eax
  801ee6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ee9:	39 f0                	cmp    %esi,%eax
  801eeb:	75 e2                	jne    801ecf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801eed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ef2:	5b                   	pop    %ebx
  801ef3:	5e                   	pop    %esi
  801ef4:	5d                   	pop    %ebp
  801ef5:	c3                   	ret    

00801ef6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	53                   	push   %ebx
  801efa:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801efd:	89 c1                	mov    %eax,%ecx
  801eff:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801f02:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f06:	eb 0a                	jmp    801f12 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801f08:	0f b6 10             	movzbl (%eax),%edx
  801f0b:	39 da                	cmp    %ebx,%edx
  801f0d:	74 07                	je     801f16 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f0f:	83 c0 01             	add    $0x1,%eax
  801f12:	39 c8                	cmp    %ecx,%eax
  801f14:	72 f2                	jb     801f08 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801f16:	5b                   	pop    %ebx
  801f17:	5d                   	pop    %ebp
  801f18:	c3                   	ret    

00801f19 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	57                   	push   %edi
  801f1d:	56                   	push   %esi
  801f1e:	53                   	push   %ebx
  801f1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f25:	eb 03                	jmp    801f2a <strtol+0x11>
		s++;
  801f27:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f2a:	0f b6 01             	movzbl (%ecx),%eax
  801f2d:	3c 20                	cmp    $0x20,%al
  801f2f:	74 f6                	je     801f27 <strtol+0xe>
  801f31:	3c 09                	cmp    $0x9,%al
  801f33:	74 f2                	je     801f27 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801f35:	3c 2b                	cmp    $0x2b,%al
  801f37:	75 0a                	jne    801f43 <strtol+0x2a>
		s++;
  801f39:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801f3c:	bf 00 00 00 00       	mov    $0x0,%edi
  801f41:	eb 11                	jmp    801f54 <strtol+0x3b>
  801f43:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801f48:	3c 2d                	cmp    $0x2d,%al
  801f4a:	75 08                	jne    801f54 <strtol+0x3b>
		s++, neg = 1;
  801f4c:	83 c1 01             	add    $0x1,%ecx
  801f4f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f54:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f5a:	75 15                	jne    801f71 <strtol+0x58>
  801f5c:	80 39 30             	cmpb   $0x30,(%ecx)
  801f5f:	75 10                	jne    801f71 <strtol+0x58>
  801f61:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f65:	75 7c                	jne    801fe3 <strtol+0xca>
		s += 2, base = 16;
  801f67:	83 c1 02             	add    $0x2,%ecx
  801f6a:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f6f:	eb 16                	jmp    801f87 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801f71:	85 db                	test   %ebx,%ebx
  801f73:	75 12                	jne    801f87 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f75:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f7a:	80 39 30             	cmpb   $0x30,(%ecx)
  801f7d:	75 08                	jne    801f87 <strtol+0x6e>
		s++, base = 8;
  801f7f:	83 c1 01             	add    $0x1,%ecx
  801f82:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f87:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f8f:	0f b6 11             	movzbl (%ecx),%edx
  801f92:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f95:	89 f3                	mov    %esi,%ebx
  801f97:	80 fb 09             	cmp    $0x9,%bl
  801f9a:	77 08                	ja     801fa4 <strtol+0x8b>
			dig = *s - '0';
  801f9c:	0f be d2             	movsbl %dl,%edx
  801f9f:	83 ea 30             	sub    $0x30,%edx
  801fa2:	eb 22                	jmp    801fc6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801fa4:	8d 72 9f             	lea    -0x61(%edx),%esi
  801fa7:	89 f3                	mov    %esi,%ebx
  801fa9:	80 fb 19             	cmp    $0x19,%bl
  801fac:	77 08                	ja     801fb6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801fae:	0f be d2             	movsbl %dl,%edx
  801fb1:	83 ea 57             	sub    $0x57,%edx
  801fb4:	eb 10                	jmp    801fc6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801fb6:	8d 72 bf             	lea    -0x41(%edx),%esi
  801fb9:	89 f3                	mov    %esi,%ebx
  801fbb:	80 fb 19             	cmp    $0x19,%bl
  801fbe:	77 16                	ja     801fd6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801fc0:	0f be d2             	movsbl %dl,%edx
  801fc3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801fc6:	3b 55 10             	cmp    0x10(%ebp),%edx
  801fc9:	7d 0b                	jge    801fd6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801fcb:	83 c1 01             	add    $0x1,%ecx
  801fce:	0f af 45 10          	imul   0x10(%ebp),%eax
  801fd2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801fd4:	eb b9                	jmp    801f8f <strtol+0x76>

	if (endptr)
  801fd6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801fda:	74 0d                	je     801fe9 <strtol+0xd0>
		*endptr = (char *) s;
  801fdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fdf:	89 0e                	mov    %ecx,(%esi)
  801fe1:	eb 06                	jmp    801fe9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801fe3:	85 db                	test   %ebx,%ebx
  801fe5:	74 98                	je     801f7f <strtol+0x66>
  801fe7:	eb 9e                	jmp    801f87 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801fe9:	89 c2                	mov    %eax,%edx
  801feb:	f7 da                	neg    %edx
  801fed:	85 ff                	test   %edi,%edi
  801fef:	0f 45 c2             	cmovne %edx,%eax
}
  801ff2:	5b                   	pop    %ebx
  801ff3:	5e                   	pop    %esi
  801ff4:	5f                   	pop    %edi
  801ff5:	5d                   	pop    %ebp
  801ff6:	c3                   	ret    

00801ff7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ff7:	55                   	push   %ebp
  801ff8:	89 e5                	mov    %esp,%ebp
  801ffa:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ffd:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802004:	75 2a                	jne    802030 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802006:	83 ec 04             	sub    $0x4,%esp
  802009:	6a 07                	push   $0x7
  80200b:	68 00 f0 bf ee       	push   $0xeebff000
  802010:	6a 00                	push   $0x0
  802012:	e8 6f e1 ff ff       	call   800186 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802017:	83 c4 10             	add    $0x10,%esp
  80201a:	85 c0                	test   %eax,%eax
  80201c:	79 12                	jns    802030 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80201e:	50                   	push   %eax
  80201f:	68 83 25 80 00       	push   $0x802583
  802024:	6a 23                	push   $0x23
  802026:	68 20 2a 80 00       	push   $0x802a20
  80202b:	e8 22 f6 ff ff       	call   801652 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802030:	8b 45 08             	mov    0x8(%ebp),%eax
  802033:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802038:	83 ec 08             	sub    $0x8,%esp
  80203b:	68 62 20 80 00       	push   $0x802062
  802040:	6a 00                	push   $0x0
  802042:	e8 8a e2 ff ff       	call   8002d1 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802047:	83 c4 10             	add    $0x10,%esp
  80204a:	85 c0                	test   %eax,%eax
  80204c:	79 12                	jns    802060 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80204e:	50                   	push   %eax
  80204f:	68 83 25 80 00       	push   $0x802583
  802054:	6a 2c                	push   $0x2c
  802056:	68 20 2a 80 00       	push   $0x802a20
  80205b:	e8 f2 f5 ff ff       	call   801652 <_panic>
	}
}
  802060:	c9                   	leave  
  802061:	c3                   	ret    

00802062 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802062:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802063:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802068:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80206a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80206d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802071:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802076:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80207a:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80207c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80207f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802080:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802083:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802084:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802085:	c3                   	ret    

00802086 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	56                   	push   %esi
  80208a:	53                   	push   %ebx
  80208b:	8b 75 08             	mov    0x8(%ebp),%esi
  80208e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802091:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802094:	85 c0                	test   %eax,%eax
  802096:	75 12                	jne    8020aa <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802098:	83 ec 0c             	sub    $0xc,%esp
  80209b:	68 00 00 c0 ee       	push   $0xeec00000
  8020a0:	e8 91 e2 ff ff       	call   800336 <sys_ipc_recv>
  8020a5:	83 c4 10             	add    $0x10,%esp
  8020a8:	eb 0c                	jmp    8020b6 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020aa:	83 ec 0c             	sub    $0xc,%esp
  8020ad:	50                   	push   %eax
  8020ae:	e8 83 e2 ff ff       	call   800336 <sys_ipc_recv>
  8020b3:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020b6:	85 f6                	test   %esi,%esi
  8020b8:	0f 95 c1             	setne  %cl
  8020bb:	85 db                	test   %ebx,%ebx
  8020bd:	0f 95 c2             	setne  %dl
  8020c0:	84 d1                	test   %dl,%cl
  8020c2:	74 09                	je     8020cd <ipc_recv+0x47>
  8020c4:	89 c2                	mov    %eax,%edx
  8020c6:	c1 ea 1f             	shr    $0x1f,%edx
  8020c9:	84 d2                	test   %dl,%dl
  8020cb:	75 2d                	jne    8020fa <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020cd:	85 f6                	test   %esi,%esi
  8020cf:	74 0d                	je     8020de <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8020d6:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020dc:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020de:	85 db                	test   %ebx,%ebx
  8020e0:	74 0d                	je     8020ef <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e7:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8020ed:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f4:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8020fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5d                   	pop    %ebp
  802100:	c3                   	ret    

00802101 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802101:	55                   	push   %ebp
  802102:	89 e5                	mov    %esp,%ebp
  802104:	57                   	push   %edi
  802105:	56                   	push   %esi
  802106:	53                   	push   %ebx
  802107:	83 ec 0c             	sub    $0xc,%esp
  80210a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80210d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802110:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802113:	85 db                	test   %ebx,%ebx
  802115:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80211a:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80211d:	ff 75 14             	pushl  0x14(%ebp)
  802120:	53                   	push   %ebx
  802121:	56                   	push   %esi
  802122:	57                   	push   %edi
  802123:	e8 eb e1 ff ff       	call   800313 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802128:	89 c2                	mov    %eax,%edx
  80212a:	c1 ea 1f             	shr    $0x1f,%edx
  80212d:	83 c4 10             	add    $0x10,%esp
  802130:	84 d2                	test   %dl,%dl
  802132:	74 17                	je     80214b <ipc_send+0x4a>
  802134:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802137:	74 12                	je     80214b <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802139:	50                   	push   %eax
  80213a:	68 2e 2a 80 00       	push   $0x802a2e
  80213f:	6a 47                	push   $0x47
  802141:	68 3c 2a 80 00       	push   $0x802a3c
  802146:	e8 07 f5 ff ff       	call   801652 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80214b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80214e:	75 07                	jne    802157 <ipc_send+0x56>
			sys_yield();
  802150:	e8 12 e0 ff ff       	call   800167 <sys_yield>
  802155:	eb c6                	jmp    80211d <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802157:	85 c0                	test   %eax,%eax
  802159:	75 c2                	jne    80211d <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80215b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80215e:	5b                   	pop    %ebx
  80215f:	5e                   	pop    %esi
  802160:	5f                   	pop    %edi
  802161:	5d                   	pop    %ebp
  802162:	c3                   	ret    

00802163 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802163:	55                   	push   %ebp
  802164:	89 e5                	mov    %esp,%ebp
  802166:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802169:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80216e:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802174:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80217a:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802180:	39 ca                	cmp    %ecx,%edx
  802182:	75 13                	jne    802197 <ipc_find_env+0x34>
			return envs[i].env_id;
  802184:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80218a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80218f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802195:	eb 0f                	jmp    8021a6 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802197:	83 c0 01             	add    $0x1,%eax
  80219a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80219f:	75 cd                	jne    80216e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    

008021a8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ae:	89 d0                	mov    %edx,%eax
  8021b0:	c1 e8 16             	shr    $0x16,%eax
  8021b3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021ba:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021bf:	f6 c1 01             	test   $0x1,%cl
  8021c2:	74 1d                	je     8021e1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021c4:	c1 ea 0c             	shr    $0xc,%edx
  8021c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021ce:	f6 c2 01             	test   $0x1,%dl
  8021d1:	74 0e                	je     8021e1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021d3:	c1 ea 0c             	shr    $0xc,%edx
  8021d6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021dd:	ef 
  8021de:	0f b7 c0             	movzwl %ax,%eax
}
  8021e1:	5d                   	pop    %ebp
  8021e2:	c3                   	ret    
  8021e3:	66 90                	xchg   %ax,%ax
  8021e5:	66 90                	xchg   %ax,%ax
  8021e7:	66 90                	xchg   %ax,%ax
  8021e9:	66 90                	xchg   %ax,%ax
  8021eb:	66 90                	xchg   %ax,%ax
  8021ed:	66 90                	xchg   %ax,%ax
  8021ef:	90                   	nop

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
